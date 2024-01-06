// Drift app example
// https://github.com/simolus3/drift/blob/develop/examples/app/lib/database/connection/connection.dart

// We use a conditional export to expose the right connection factory depending
// on the platform.
export 'unsupported.dart'
    if (dart.library.js) 'web.dart'
    if (dart.library.ffi) 'native.dart';
