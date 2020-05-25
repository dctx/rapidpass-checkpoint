import 'app.dart';
import 'flavor.dart';

void main() {
  final flavor = Flavor(
      environment: Environment.dev,
      apiBaseUrl: 'https://rapidpass-api-stage.azurewebsites.net/api/v1/',
      keycloakRealm: 'rapidpass-dashboard-dev',
      keycloakClient: 'rapidpass-dashboard-staging'
  );
  runRapidPassCheckpoint(flavor);
}
