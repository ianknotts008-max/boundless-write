//! FFI bridge for Rust <-> Dart (Flutter)
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_uchar, c_uint};
use crate::doc_graph::{DocumentGraph, Formatting};
use crate::parser::{FileParser, FileFormat};
use std::sync::Mutex;

lazy_static::lazy_static! {
    static ref DOCUMENT: Mutex<DocumentGraph> = Mutex::new(DocumentGraph::new());
}

/// Test function to verify FFI is working
#[no_mangle]
pub extern "C" fn bwe_hello() -> *mut c_char {
    CString::new("Hello from BWE core!").unwrap().into_raw()
}

/// Create a new document
#[no_mangle]
pub extern "C" fn bwe_new_document() -> *mut c_char {
    let mut doc = DOCUMENT.lock().unwrap();
    doc.clear();
    CString::new(r#"{"status":"ok","message":"New document created"}"#).unwrap().into_raw()
}

/// Insert text at a position
#[no_mangle]
pub extern "C" fn bwe_insert_text(text: *const c_char, position: c_uint) -> *mut c_char {
    if text.is_null() {
        return error_response("Text pointer is null");
    }

    let text_str = match unsafe { CStr::from_ptr(text) }.to_str() {
        Ok(s) => s,
        Err(_) => return error_response("Invalid UTF-8 in text"),
    };

    let mut doc = DOCUMENT.lock().unwrap();

    // For Phase 1: insert into first node if it exists, otherwise create new
    let node_id = doc.nodes.iter().next().map(|n| n.id);

    if let Some(id) = node_id {
        if let Err(e) = doc.insert_text_at(id, text_str, position as usize) {
            return error_response(&format!("Insert failed: {}", e));
        }
    } else {
        doc.insert_node(text_str.to_string(), Formatting::default());
    }

    match serialize_doc_to_json(&doc) {
        Ok(json) => CString::new(json).unwrap().into_raw(),
        Err(e) => error_response(&format!("Serialization failed: {}", e)),
    }
}

/// Delete text from a range
#[no_mangle]
pub extern "C" fn bwe_delete_text(start: c_uint, end: c_uint) -> *mut c_char {
    let mut doc = DOCUMENT.lock().unwrap();

    let node_id = doc.nodes.iter().next().map(|n| n.id);
    if let Some(id) = node_id {
        if let Err(e) = doc.delete_text(id, start as usize, end as usize) {
            return error_response(&format!("Delete failed: {}", e));
        }
    }

    match serialize_doc_to_json(&doc) {
        Ok(json) => CString::new(json).unwrap().into_raw(),
        Err(e) => error_response(&format!("Serialization failed: {}", e)),
    }
}

/// Get the current document as JSON
#[no_mangle]
pub extern "C" fn bwe_get_document() -> *mut c_char {
    let doc = DOCUMENT.lock().unwrap();
    match serialize_doc_to_json(&doc) {
        Ok(json) => CString::new(json).unwrap().into_raw(),
        Err(e) => error_response(&format!("Serialization failed: {}", e)),
    }
}

/// Get document statistics (word count, char count, page count)
#[no_mangle]
pub extern "C" fn bwe_get_stats() -> *mut c_char {
    let doc = DOCUMENT.lock().unwrap();
    let stats = format!(
        r#"{{"word_count":{},"char_count":{},"page_count":{}}}"#,
        doc.word_count(),
        doc.char_count(),
        doc.page_count()
    );
    CString::new(stats).unwrap().into_raw()
}

/// Load a document from bytes
#[no_mangle]
pub extern "C" fn bwe_load_document(
    data: *const c_uchar,
    len: c_uint,
    format: *const c_char,
) -> *mut c_char {
    if data.is_null() || format.is_null() {
        return error_response("Null pointer passed to bwe_load_document");
    }

    let format_str = match unsafe { CStr::from_ptr(format) }.to_str() {
        Ok(s) => s,
        Err(_) => return error_response("Invalid UTF-8 in format string"),
    };

    let file_format = match format_str {
        "txt" => FileFormat::Txt,
        "bwe" => FileFormat::Bwe,
        _ => return error_response("Unsupported format (Phase 1 supports: txt, bwe)"),
    };

    let data_slice = unsafe { std::slice::from_raw_parts(data, len as usize) };

    match FileParser::parse(data_slice, file_format) {
        Ok(parsed_graph) => {
            let mut doc = DOCUMENT.lock().unwrap();
            *doc = parsed_graph;
            CString::new(r#"{"status":"ok","message":"Document loaded"}"#).unwrap().into_raw()
        }
        Err(e) => error_response(&format!("Parse error: {}", e)),
    }
}

/// Save the current document to bytes
#[no_mangle]
pub extern "C" fn bwe_save_document(format: *const c_char) -> *mut c_uchar {
    if format.is_null() {
        return std::ptr::null_mut();
    }

    let format_str = match unsafe { CStr::from_ptr(format) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let file_format = match format_str {
        "txt" => FileFormat::Txt,
        "bwe" => FileFormat::Bwe,
        _ => return std::ptr::null_mut(),
    };

    let doc = DOCUMENT.lock().unwrap();

    match FileParser::serialize(&doc, file_format) {
        Ok(bytes) => {
            let boxed = bytes.into_boxed_slice();
            Box::into_raw(boxed) as *mut c_uchar
        }
        Err(_) => std::ptr::null_mut(),
    }
}

/// Get the size of the last saved document (to know how many bytes to read)
#[no_mangle]
pub extern "C" fn bwe_get_document_size(format: *const c_char) -> c_uint {
    if format.is_null() {
        return 0;
    }

    let format_str = match unsafe { CStr::from_ptr(format) }.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };

    let file_format = match format_str {
        "txt" => FileFormat::Txt,
        "bwe" => FileFormat::Bwe,
        _ => return 0,
    };

    let doc = DOCUMENT.lock().unwrap();

    match FileParser::serialize(&doc, file_format) {
        Ok(bytes) => bytes.len() as c_uint,
        Err(_) => 0,
    }
}

/// Free a C string allocated by FFI functions
#[no_mangle]
pub extern "C" fn bwe_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}

/// Free a byte buffer allocated by FFI functions
#[no_mangle]
pub extern "C" fn bwe_free_buffer(ptr: *mut c_uchar, _len: c_uint) {
    if !ptr.is_null() {
        unsafe {
            let _ = Vec::from_raw_parts(ptr, _len as usize, _len as usize);
        }
    }
}

// ===== Helper Functions =====

fn serialize_doc_to_json(doc: &DocumentGraph) -> Result<String, String> {
    serde_json::to_string(doc)
        .map_err(|e| format!("JSON serialization failed: {}", e))
}

fn error_response(message: &str) -> *mut c_char {
    let json = format!(r#"{{"status":"error","message":"{}"}}"#, message);
    CString::new(json).unwrap_or_else(|_| CString::new("{}").unwrap()).into_raw()
}
