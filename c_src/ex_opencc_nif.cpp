#include "erl_nif.h"
#include <iostream>
#include <string>
#include <memory>

// Include OpenCC headers
#include "Config.hpp"
#include "Converter.hpp"

using namespace opencc;

// Resource type for OpenCC converter
static ErlNifResourceType* opencc_resource_type = nullptr;

// Converter resource structure
struct OpenccResource {
    std::shared_ptr<Converter> converter;
    
    OpenccResource(std::shared_ptr<Converter> conv) : converter(std::move(conv)) {}
};

// Resource cleanup function
static void opencc_resource_cleanup(ErlNifEnv* env, void* obj) {
    OpenccResource* resource = static_cast<OpenccResource*>(obj);
    resource->~OpenccResource();
}

// Helper function to convert Erlang binary to std::string
static std::string erl_binary_to_string(ErlNifEnv* env, ERL_NIF_TERM term) {
    ErlNifBinary binary;
    if (!enif_inspect_binary(env, term, &binary)) {
        return "";
    }
    return std::string(reinterpret_cast<char*>(binary.data), binary.size);
}

// Helper function to convert std::string to Erlang binary
static ERL_NIF_TERM string_to_erl_binary(ErlNifEnv* env, const std::string& str) {
    ERL_NIF_TERM term;
    unsigned char* ptr = enif_make_new_binary(env, str.length(), &term);
    memcpy(ptr, str.c_str(), str.length());
    return term;
}

// NIF function: new/1 - Create new OpenCC converter
static ERL_NIF_TERM opencc_new(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    std::string config_file = "s2t.json"; // default config
                                          //
    
    if (argc >= 1) {
        config_file = erl_binary_to_string(env, argv[0]);
        if (config_file.empty()) {
            return enif_make_tuple2(env, 
                enif_make_atom(env, "error"), 
                enif_make_atom(env, "invalid_config_file"));
        }
    }

    try {
        Config config;
        auto converter = config.NewFromFile(config_file);
        
        // Allocate resource
        OpenccResource* resource = static_cast<OpenccResource*>(
            enif_alloc_resource(opencc_resource_type, sizeof(OpenccResource)));
        
        if (resource == nullptr) {
            return enif_make_tuple2(env, 
                enif_make_atom(env, "error"), 
                enif_make_atom(env, "allocation_failed"));
        }
        
        // Use placement new to construct the resource
        new(resource) OpenccResource(std::move(converter));
        
        ERL_NIF_TERM resource_term = enif_make_resource(env, resource);
        enif_release_resource(resource);
        
        return enif_make_tuple2(env, enif_make_atom(env, "ok"), resource_term);
        
    } catch (const std::exception& e) {
        return enif_make_tuple2(env, 
            enif_make_atom(env, "error"), 
            string_to_erl_binary(env, e.what()));
    } catch (...) {
        return enif_make_tuple2(env, 
            enif_make_atom(env, "error"), 
            enif_make_atom(env, "unknown_error"));
    }
}

// NIF function: convert_sync/2 - Convert text synchronously
static ERL_NIF_TERM opencc_convert_sync(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 2) {
        return enif_make_badarg(env);
    }
    
    // Get resource
    OpenccResource* resource;
    if (!enif_get_resource(env, argv[0], opencc_resource_type, reinterpret_cast<void**>(&resource))) {
        return enif_make_tuple2(env, 
            enif_make_atom(env, "error"), 
            enif_make_atom(env, "invalid_converter"));
    }
    
    // Get input text
    std::string input = erl_binary_to_string(env, argv[1]);
    if (input.empty() && !enif_is_binary(env, argv[1])) {
        return enif_make_tuple2(env, 
            enif_make_atom(env, "error"), 
            enif_make_atom(env, "invalid_input"));
    }
    
    try {
        if (!resource->converter) {
            return enif_make_tuple2(env, 
                enif_make_atom(env, "error"), 
                enif_make_atom(env, "converter_not_initialized"));
        }
        
        std::string output = resource->converter->Convert(input);
        return enif_make_tuple2(env, 
            enif_make_atom(env, "ok"), 
            string_to_erl_binary(env, output));
            
    } catch (const std::exception& e) {
        return enif_make_tuple2(env, 
            enif_make_atom(env, "error"), 
            string_to_erl_binary(env, e.what()));
    } catch (...) {
        return enif_make_tuple2(env, 
            enif_make_atom(env, "error"), 
            enif_make_atom(env, "unknown_error"));
    }
}

// NIF function exports
static ErlNifFunc nif_funcs[] = {
    {"new", 0, opencc_new},
    {"new", 1, opencc_new},
    {"convert_sync", 2, opencc_convert_sync}
};

// NIF module initialization
static int load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
    ErlNifResourceFlags flags = static_cast<ErlNifResourceFlags>(ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER);
    opencc_resource_type = enif_open_resource_type(
        env, NULL, "opencc_converter", 
        opencc_resource_cleanup, 
        flags,
        NULL);
    
    if (opencc_resource_type == nullptr) {
        return -1;
    }
    
    return 0;
}

ERL_NIF_INIT(Elixir.ExOpencc, nif_funcs, load, NULL, NULL, NULL)
