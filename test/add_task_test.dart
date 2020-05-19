
import 'package:flutter_test/flutter_test.dart';
import 'package:todoeight/screens/my_homepage.dart';

void main() {
  group('String', (){
    test('Empty task return error', (){
      var result = AddTaskValidator.validate('');
      expect(result, 'Forgot to enter task ?');
    });
    test('Non-Empty task return null', (){
      var result = AddTaskValidator.validate('taskName');
      expect(result, null);
    });
  });

}
