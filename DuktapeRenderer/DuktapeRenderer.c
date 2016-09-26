#import "DuktapeRenderer.h"

#include "duktape.h"

void handleError(duk_context* ctx, duk_errcode_t code, const char* m) {
	printf("Error: %d: %s\n", code, m);
}

// WARNING: This is a very quick & dirty implementation for now, and doesn't
// work in the real world: it cannot handle exceptions in the JavaScript 
// (it just makes the app crash).
char* callRender(const char* file, const char* arg) {
	duk_context* ctx = duk_create_heap(NULL, NULL, NULL, NULL, &handleError);
	duk_eval_file_noresult(ctx, file);
	duk_eval_string(ctx, "(function myRender(s) { return JSON.stringify(server.render(JSON.parse(s))); })");
	duk_dup(ctx, -1);
	duk_push_string(ctx, arg);
	duk_call(ctx, 1);
	char* result = strdup(duk_to_string(ctx, -1));
	duk_pop(ctx);
	duk_destroy_heap(ctx);

	return result;
}
