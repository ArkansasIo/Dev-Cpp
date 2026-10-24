// UML — Blueprint system (Unreal Engine 5 style visual-scripting graph, code-driven)
// Nodes have typed pins; wires connect outputs to inputs; graph executes as a DAG.
use serde::Deserialize;
use std::collections::HashMap;

#[derive(Deserialize, Debug, Clone)]
pub struct Node {
    pub id: String,
    pub op: String,
    #[serde(default)]
    pub params: HashMap<String, f64>,
    #[serde(default)]
    pub inputs: Vec<String>, // ids of nodes feeding this node (in order)
}

#[derive(Deserialize, Debug)]
pub struct Graph {
    #[allow(dead_code)] // kept for error messages / future graph listings
    pub name: String,
    pub nodes: Vec<Node>,
    /// optional: id of output node
    #[serde(default)]
    pub output: Option<String>,
}

pub fn run_json(json: &str, input: f64) -> Result<f64, String> {
    let g: Graph = serde_json::from_str(json).map_err(|e| format!("bad graph: {}", e))?;
    let mut values: HashMap<String, f64> = HashMap::new();

    // topological-ish evaluation: resolve iteratively (handles DAGs)
    let mut pending: Vec<&Node> = g.nodes.iter().collect();
    let mut guard = 0;
    while !pending.is_empty() {
        guard += 1;
        if guard > 10_000 { return Err("graph has a cycle or is unresolvable".into()); }
        let mut progress = false;
        pending.retain(|n| {
            let ready = n.inputs.iter().all(|i| values.contains_key(i));
            if !ready { return true; }
            let ins: Vec<f64> = n.inputs.iter().map(|i| values[i]).collect();
            values.insert(n.id.clone(), eval_node(n, ins, input));
            progress = true;
            false
        });
        if !progress && !pending.is_empty() {
            return Err("cycle detected in blueprint graph".into());
        }
    }

    // output: named output node, else last node
    let out_id = g.output.or_else(|| g.nodes.last().map(|n| n.id.clone()))
        .ok_or("empty graph")?;
    values.get(&out_id).copied().ok_or_else(|| format!("output node '{}' missing", out_id))
}

fn eval_node(n: &Node, ins: Vec<f64>, input: f64) -> f64 {
    let get = |i: usize| ins.get(i).copied().unwrap_or(0.0);
    let p = |k: &str| *n.params.get(k).unwrap_or(&0.0);
    match n.op.as_str() {
        // inputs & constants
        "input" => input,
        "const" => p("value"),
        // arithmetic
        "add" | "+" => get(0) + get(1),
        "sub" | "-" => get(0) - get(1),
        "mul" | "*" => get(0) * get(1),
        "div" | "/" => { let b = get(1); if b == 0.0 { f64::NAN } else { get(0) / b } }
        "pow" | "^" => get(0).powf(get(1)),
        "mod" | "%" => get(0) % get(1),
        "neg" => -get(0),
        // functions
        "sqrt" => get(0).sqrt(),
        "abs" => get(0).abs(),
        "sin" => get(0).sin(),
        "cos" => get(0).cos(),
        "tan" => get(0).tan(),
        "exp" => get(0).exp(),
        "ln" => get(0).ln(),
        "floor" => get(0).floor(),
        "ceil" => get(0).ceil(),
        "round" => get(0).round(),
        "clamp" => get(0).clamp(get(1), get(2)),
        "lerp" => get(0) + (get(1) - get(0)) * get(2), // (a,b,t)
        "min" => get(0).min(get(1)),
        "max" => get(0).max(get(1)),
        // logic (UE-style: returns 1.0/0.0, clamps to bool)
        "and" => if get(0) != 0.0 && get(1) != 0.0 { 1.0 } else { 0.0 },
        "or"  => if get(0) != 0.0 || get(1) != 0.0 { 1.0 } else { 0.0 },
        "not" => if get(0) == 0.0 { 1.0 } else { 0.0 },
        "eq"  => if (get(0) - get(1)).abs() < 1e-12 { 1.0 } else { 0.0 },
        "ne"  => if (get(0) - get(1)).abs() >= 1e-12 { 1.0 } else { 0.0 },
        "gt"  => if get(0) > get(1) { 1.0 } else { 0.0 },
        "lt"  => if get(0) < get(1) { 1.0 } else { 0.0 },
        "select" => if get(2) != 0.0 { get(0) } else { get(1) }, // (A, B, cond) like UE Select
        // branches (like UE Branch node)
        "branch" => if get(0) != 0.0 { get(1) } else { get(2) },
        // loops-as-nodes: sequence of additions (n via const)
        "sum" => ins.iter().sum(),
        "product" => ins.iter().product(),
        _ => f64::NAN,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn simple_graph() {
        let json = r#"{"name":"t","nodes":[
            {"id":"a","op":"input"},
            {"id":"b","op":"const","params":{"value":2}},
            {"id":"c","op":"mul","inputs":["a","b"]}
        ],"output":"c"}"#;
        assert_eq!(run_json(json, 21.0).unwrap(), 42.0);
    }
    #[test]
    fn branch_graph() {
        let json = r#"{"name":"t","nodes":[
            {"id":"x","op":"input"},
            {"id":"ten","op":"const","params":{"value":10}},
            {"id":"gt","op":"gt","inputs":["x","ten"]},
            {"id":"big","op":"const","params":{"value":1}},
            {"id":"small","op":"const","params":{"value":0}},
            {"id":"sel","op":"select","inputs":["big","small","gt"]}
        ],"output":"sel"}"#;
        assert_eq!(run_json(json, 50.0).unwrap(), 1.0);
        assert_eq!(run_json(json, 5.0).unwrap(), 0.0);
    }
}
