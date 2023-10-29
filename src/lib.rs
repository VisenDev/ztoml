use std::ffi::CString;
use std::os::raw::c_char;

#[no_mangle]
pub extern "C" fn tomlToJson(input: *const c_char) -> *mut c_char {
    use std::ffi::CStr;
    let c_str: &CStr = unsafe { CStr::from_ptr(input) };
    let str_slice: &str = match c_str.to_str().ok() {
        Some(value) => value,
        None => {
            eprintln!("Error: Failed to convert toml to json");
            return std::ptr::null(); // Return from the main function
        }
    };
    //let str_buf: String = str_slice.to_owned();

    let value = toml::from_str::<toml::Value>(&str_slice)
        .ok(); // Use the `ok` method to convert the `Result` to an `Option`

    let json_string = match value {
        Some(value) => serde_json::to_string(&value).ok(), // Use the `ok` method to convert the `Result` to an `Option`
        None => None, // Return `None` if an error occurred
    };

    let c_string = match json_string {
        Some(json_string) => CString::new(json_string).ok(), // Use the `ok` method to convert the `Result` to an `Option`
        None => None, // Return `None` if an error occurred
    };

    match c_string {
        Some(c_string) => c_string.into_raw(),
        None => std::ptr::null_mut(), // Return a null pointer if an error occurred
    }
}

#[no_mangle]
pub extern "C" fn tomlToJsonFree(ptr: *mut c_char) {
    if !ptr.is_null() {
	    let _ = CString::from_raw(ptr);
    }
}
