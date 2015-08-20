// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: google/protobuf/source_context.proto

#import "GPBProtocolBuffers.h"

#if GOOGLE_PROTOBUF_OBJC_GEN_VERSION != 30000
#error This file was generated by a different version of protoc-gen-objc which is incompatible with your Protocol Buffer sources.
#endif

// @@protoc_insertion_point(imports)

CF_EXTERN_C_BEGIN


#pragma mark - GPBSourceContextRoot

@interface GPBSourceContextRoot : GPBRootObject

// The base class provides:
//   + (GPBExtensionRegistry *)extensionRegistry;
// which is an GPBExtensionRegistry that includes all the extensions defined by
// this file and all files that it depends on.

@end

#pragma mark - GPBSourceContext

typedef GPB_ENUM(GPBSourceContext_FieldNumber) {
  GPBSourceContext_FieldNumber_FileName = 1,
};

// `SourceContext` represents information about the source of a
// protobuf element, like the file in which it is defined.
@interface GPBSourceContext : GPBMessage

// The path-qualified name of the .proto file that contained the associated
// protobuf element.  For example: `"google/protobuf/source.proto"`.
@property(nonatomic, readwrite, copy) NSString *fileName;

@end

CF_EXTERN_C_END

// @@protoc_insertion_point(global_scope)
