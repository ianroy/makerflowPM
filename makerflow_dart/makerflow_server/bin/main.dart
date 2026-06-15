import 'package:makerflow_server/server.dart';

// Server entrypoint.
//   dart bin/main.dart                    # run
//   dart bin/main.dart --apply-migrations # run pending migrations then serve
void main(List<String> args) async {
  await run(args);
}
