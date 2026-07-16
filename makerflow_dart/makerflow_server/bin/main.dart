import 'package:makerflow_server/server.dart';

// Server entrypoint (compiled to /app/server in the runtime image).
//   dart bin/main.dart                    # serve
//   dart bin/main.dart --apply-migrations # run pending migrations then serve
//   dart bin/main.dart --mode production --seed  # seed once, then exit (no serve)
void main(List<String> args) async {
  await run(args);
}
