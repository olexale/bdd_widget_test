const setUpMethodName = 'bddSetUp';
const tearDownMethodName = 'bddTearDown';
const testSuccessVariableName = 'success';

const hookClass = 'Hooks';
const hookFileName = 'hooks';
const setUpHookName = 'beforeEach';
const tearDownHookName = 'afterEach';
const setUpAllHookName = 'beforeAll';
const tearDownAllHookName = 'afterAll';

const worldVarName = 'world';
const worldTypeName = 'World';

const worldParameter = '$worldTypeName $worldVarName';

//https://api.flutter.dev/flutter/flutter_test/setUpAll.html
const setUpAllCallbackName = 'setUpAll';

//https://api.flutter.dev/flutter/flutter_test/tearDownAll.html
const tearDownAllCallbackName = 'tearDownAll';

const testMethodNameTag = '@testMethodName:';

/// [testerTypeTag] to specify the tester type to use for the test.
/// The default testerTypeTag value is `WidgetTester`.
/// should be on the top level of a feature file or inside build.yaml options
const testerTypeTag = '@testerType:';

/// [testerNameTag] specifies the tester name to use, the default value is tester
/// should be on the top level of a feature file or inside build.yaml options
const testerNameTag = '@testerName:';

/// [scenarioParamsTag] can be used to filter custom parameters for
/// scenario functions for example: @scenarioParams: skip: false, timeout: Timeout(Duration(seconds: 1))
/// because some test packaages like `patrol` support this.
const scenarioParamsTag = '@scenarioParams:';

const testFolderName = 'test';
