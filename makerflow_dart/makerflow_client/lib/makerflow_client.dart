/// Public entry for the generated Serverpod client.
/// `serverpod generate` writes the implementation under `src/protocol/`;
/// this barrel re-exports the `Client` and all protocol types/exceptions.
library makerflow_client;

export 'src/protocol/client.dart';
export 'src/protocol/protocol.dart';
