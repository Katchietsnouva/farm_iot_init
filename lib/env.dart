// https://grok.com/chat/405e9c39-92b9-49f1-83ce-7da82fa85f15
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'AZURE_DEPLOYMENT_TOKEN', obfuscate: true)
  static String apiKey = _Env.apiKey;
}
