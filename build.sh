#!/bin/sh

# Build config
EMCC=../emscripten/emcc
NACL_SDK_ROOT=../../nacl_sdk/pepper_25
set -x verbose
set -e

# Make sure the main output directory exists.
mkdir -p out

FLAGS="-std=c++11 -O0 --closure 0 --minify 0 --js-library library_ppapi.js --pre-js ppapi.js -I$NACL_SDK_ROOT/include"

# Files that are normally compiled into libppapi_cpp.
D=$NACL_SDK_ROOT/src/ppapi_cpp
PPAPI_CPP="$D/ppp_entrypoints.cc $D/module.cc $D/instance.cc $D/instance_handle.cc $D/var.cc $D/url_request_info.cc $D/url_response_info.cc $D/url_loader.cc $D/resource.cc $D/lock.cc $D/input_event.cc $D/view.cc"

example() {
  NAME=$1
  IN_DIR=examples/$NAME
  OUT_DIR=out/$NAME

  # Make sure the output directory exists.
  mkdir -p $OUT_DIR

  # Stage data requried to run in the browser.
  cp examples/common.js $IN_DIR/*.html $IN_DIR/*.js $OUT_DIR
}

example "hello_world"
SOURCES="$IN_DIR/hello_world.cc"
$EMCC $FLAGS ppapi_stub.cc $SOURCES -o $OUT_DIR/$NAME.js -s EXPORTED_FUNCTIONS="['_Startup']"

example "geturl"
SOURCES="$IN_DIR/geturl.cc $IN_DIR/geturl_handler.cc"
$EMCC $FLAGS $PPAPI_CPP ppapi_stub.cc $SOURCES -o $OUT_DIR/$NAME.js -s EXPORTED_FUNCTIONS="['_Startup']"
