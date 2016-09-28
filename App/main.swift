import Vapor
import Jay
#if os(Linux)
import CDuktape
#else
import JavaScriptCore
#endif

let jsFile = "Resources/server.js"

////////////////////////////////////////////////////////////////////////////////
// Linux
////////////////////////////////////////////////////////////////////////////////

#if os(Linux)

/* Helper to convert any value into JSON */
// Note: Jay has a bug on OS X that it doesn't convert [String->Int] mappings 
// properly: https://github.com/DanToml/Jay/issues/52
// Once (and if) this is fixed, we can drop the OSX-specific JSONSerialization 
// implementation in favor of this one.
func toJSON(value: Any) -> String? {
	if let data = try? Jay().dataFromJson(any: value) {
		return String(bytes: data, encoding: String.Encoding.utf8)
	}
	else {
		return nil
	}
}

func render(state: [String: Any]) -> [AnyHashable : Any]? {
	if let stateJSON = toJSON(value: state) {
		let ctx = duk_create_heap(nil, nil, nil, nil, nil)
		duk_eval_file_noresult(ctx, jsFile)
		duk_push_global_object(ctx)
		duk_get_prop_string(ctx, -1, "server")
		duk_get_prop_string(ctx, -1, "render")
		duk_push_string(ctx, stateJSON)
		duk_json_decode(ctx, -1)
		let ret = duk_safe_call(ctx, { (_ ctx: OpaquePointer?) -> duk_ret_t in
			duk_call(ctx, 1);
			return 1;
		}, 1, 1);
		if ret != DUK_EXEC_SUCCESS {
			let errorMessage = String(validatingUTF8: duk_safe_to_string(ctx, -1))!
			print("Error calling render(): \(errorMessage)")
			duk_pop(ctx)
			duk_destroy_heap(ctx)
			return nil
		}
		else {
			duk_json_encode(ctx, -1)
			let resultJSON = String(validatingUTF8: duk_to_string(ctx, -1))!
			duk_pop(ctx)
			duk_destroy_heap(ctx)
			if let result = try? Jay().anyJsonFromData(Array(resultJSON.utf8)) {
				return result as! [String: Any]
			}
		}
	}
	return nil
}

#else

////////////////////////////////////////////////////////////////////////////////
// OS X
////////////////////////////////////////////////////////////////////////////////

/* Helper to convert any value into JSON */
func toJSON(value: Any) -> String? {
	if let data = try? JSONSerialization.data(withJSONObject: value) {
		return String(data: data, encoding: .utf8)
	}
	else {
		return nil
	}
}

/* Helper to load the JavaScript server code */
func loadJS() -> JSValue? {
	let context = JSContext()
	context?.exceptionHandler = { context, exception in
		print("JS Error: \(exception)")
	}
	do {
		let js = try String(contentsOfFile: jsFile, encoding: String.Encoding.utf8)
		_ = context?.evaluateScript(js)
	} 
	catch (let error) {
		print("Error while processing script file: \(error)")
		return nil
	}
	return context?.objectForKeyedSubscript("server")
}

/* Helper to call the JavaScript render() function */
func render(state: [String: Any]) -> [AnyHashable : Any]? {
	return loadJS()?.forProperty("render")?
		.call(withArguments: [state]).toDictionary()
}

#endif

////////////////////////////////////////////////////////////////////////////////

/* Dummy DB */
func getStateFromDB() -> [String: Any] {
	return [
		"value": 42,
	]
}

////////////////////////////////////////////////////////////////////////////////

let drop = Droplet(
	serverMiddleware: [ "file", "abort" ]
)

drop.get("/") { req in
	if req.headers["X-DevServer"] != nil {
		// When accessing through the dev server, don't prerender anything
		return try drop.view.make("index", [
			"html": "",
			"state": "undefined"
		])
	}
	else {
		// Prerender state from the DB
		let state = getStateFromDB()
		if let result = render(state: state) {
			if let html = result["html"] as? String, let state = result["state"] as? String {
				return try drop.view.make("index", [
					"html": Node.string(html),
					"state": Node.string(state)
				])
			}
		}
		else {
			let json = toJSON(value: state)!.replacingOccurrences(of: "'", with: "'\\''")
			print("To get more information, run:")
			print("  ./renderComponent '\(json)'")
		}
		throw Abort.badRequest
	}
}

drop.get("/api/state") { req in
	if let state = toJSON(value: getStateFromDB()) {
		return state
	}
	else {
		throw Abort.badRequest
	}
}

drop.run()
