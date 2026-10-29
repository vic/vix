//! The slice of jq semantics the bash scripts rely on.
//! Probed on jq 1.8.2: `a // b` does NOT swallow errors from `a`; indexing a
//! non-object non-null value is an error that aborts the whole filter.
use serde_json::Value;

/// A jq runtime error (the filter produced no output).
#[derive(Debug, PartialEq)]
pub(crate) struct JqErr;

static NULL: Value = Value::Null;

/// `.a.b.c`: null propagates, non-object is an error.
pub(crate) fn path<'a>(v: &'a Value, keys: &[&str]) -> Result<&'a Value, JqErr> {
    keys.iter().try_fold(v, |cur, k| match cur {
        Value::Object(m) => Ok(m.get(*k).unwrap_or(&NULL)),
        Value::Null => Ok(&NULL),
        _ => Err(JqErr),
    })
}

pub(crate) fn truthy(v: &Value) -> bool {
    !matches!(v, Value::Null | Value::Bool(false))
}

/// `.a.b // .c.d // ...`: first truthy path, `Ok(None)` when all are falsy.
pub(crate) fn alt<'a>(v: &'a Value, paths: &[&[&str]]) -> Result<Option<&'a Value>, JqErr> {
    for p in paths {
        let r = path(v, p)?;
        if truthy(r) {
            return Ok(Some(r));
        }
    }
    Ok(None)
}

/// jq -c output: serde compact form, but jq escapes DEL as \u007f.
pub(crate) fn compact(v: &Value) -> String {
    v.to_string().replace('\u{7f}', "\\u007f")
}

/// `tostring`: strings stay, everything else is compact JSON.
pub(crate) fn tostring(v: &Value) -> String {
    match v {
        Value::String(s) => s.clone(),
        other => compact(other),
    }
}

/// `x[0:n]` for strings (codepoints) and arrays; anything else errors.
pub(crate) fn slice(v: &Value, n: usize) -> Result<Value, JqErr> {
    match v {
        Value::String(s) => Ok(Value::String(s.chars().take(n).collect())),
        Value::Array(a) => Ok(Value::Array(a.iter().take(n).cloned().collect())),
        Value::Null => Ok(Value::Null),
        _ => Err(JqErr),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn string_index_errors() {
        assert_eq!(path(&json!("s"), &["x"]), Err(JqErr));
        assert_eq!(path(&json!({"a": null}), &["a", "b"]), Ok(&Value::Null));
    }

    #[test]
    fn alt_picks_first_truthy() {
        let v = json!({"a": false, "b": 0});
        assert_eq!(alt(&v, &[&["a"], &["b"]]), Ok(Some(&json!(0))));
    }

    #[test]
    fn slice_is_codepoints() {
        assert_eq!(slice(&json!("héé"), 2), Ok(json!("hé")));
    }

    #[test]
    fn del_escaped() {
        assert_eq!(compact(&json!("a\u{7f}")), "\"a\\u007f\"");
    }
}
