import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:source_gen/source_gen.dart';
import 'package:meta/meta.dart';

Builder featureBuilder(BuilderOptions options) => PartBuilder([const SealedGenerator()], '.sealed.dart');

@sealed
class SealedGenerator extends GeneratorForAnnotation<Sealed> {
  const SealedGenerator();

  @override
  String generateForAnnotatedElement(
      Element element,
      ConstantReader annotation,
      BuildStep buildStep
  ) {


    final className = element.name ?? '';

    List<String> classes = <String>[];

    element.children.forEach((element) {
      if (element.displayName?.startsWith(className) == true){
        final methodName = element.name ?? '';
        final newClassName = "${methodName.capitalize()}_${className}";


        var content = '\nclass ${newClassName} implements ${className} {\n';

        //vars
        element.children.forEach((element) {
          content += '\tfinal ${element};\n';
        });

        //constructor
        content += '\tconst ${newClassName}(';
        element.children.forEachIndexed((i, element) {
          if (i != 0){
            content += ', ';
          }
          content += 'this.${element.displayName}';
        });
        content += ');\n';


        content += '}\n';

        classes.add(content);
      }
    });



    return classes.join('\n');
  }

  @override
  String toString() => 'sealed_generators';
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${this.substring(1)}";
}