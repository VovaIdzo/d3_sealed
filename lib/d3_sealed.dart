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
    List<String> classes = <String>[];


    final parentClass = element.name ?? "";
    final className = ((element.name?.startsWith("_") == true ? element.name!.substring(1) : element.name) ?? '').capitalize();
    String sealedEnumClassName = "SealedEnum${className}";


    String sealedEnumClass = 'enum ${sealedEnumClassName} {\n';
    String mainClass = 'abstract class ${className}';
    if (element is ClassElement){
      mainClass += " implements " +element.interfaces.map((e) => e.toString()).join(",");
    }
    mainClass += " {\n ";
    mainClass += "\tconst ${className}();";

    element.children.forEachIndexed((i, element) {
      if (i == 0){
        return;
      }

      final methodName = element.name ?? "";
      final newClassName = "${methodName.capitalize()}${className}";

        var content = '\nclass ${newClassName} extends ${className} {\n';

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

        content += '\t${sealedEnumClassName} get type => ${sealedEnumClassName}.${methodName};\n';

        content += '}\n';


        sealedEnumClass += "\t${methodName},\n";


        //main class factory method;
        var mainClassMethod = "\tconst factory ${className}.${methodName}(";
        element.children.forEachIndexed((i, element) {
          if (i != 0){
            mainClassMethod += ", ";
          }
          mainClassMethod += "$element";
        });
        mainClassMethod += ") = ${newClassName};\n";

        mainClass += mainClassMethod;
        mainClass += "\t${newClassName} get as${methodName.capitalize()} => this as ${newClassName};\n\n";

        classes.add(content);
    });

    sealedEnumClass += "}\n";
    mainClass += '\t${sealedEnumClassName} get type;\n';
    mainClass += '}\n';

    classes.add(sealedEnumClass);
    classes.insert(0, mainClass);

    return classes.join('\n');
  }

  @override
  String toString() => 'sealed_generators';
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${this.substring(1)}";
}