#include <stdio.h>
#include <string.h>

#include "version.h"
#include "FEAnalyzer.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

struct Arguments {
  bool version_check = false;
};

Arguments parse_args(int argc, char** argv) {
  Arguments args;
  for (int i = 1; i < argc; ++i) {
    char* arg = argv[i];
    if (strcmp(arg, "--help") == 0) {
      printf("Usage: rust [--version]\n");
    } else if (strcmp(arg, "--version") == 0) {
      args.version_check = true;
    } else {
      fprintf(stderr, "Unrecognized argument:\n%s\n", arg);
    }
  }
  return args;
}

QString version_qstring() {
  const Version& v = k_version;
  return QString("%1.%2.%3.%4")
    .arg(v.major)
    .arg(v.minor)
    .arg(v.patch)
    .arg(v.build);
}

int main(int argc, char** argv) {
  QGuiApplication app(argc, argv);
  app.setApplicationName("bridge");
  app.setApplicationVersion(version_qstring());
  app.setOrganizationDomain("rustgolem.com");
  app.setOrganizationName("RustGolem");
  Arguments args = parse_args(argc, argv);
  if (args.version_check) {
    printf("%s\n", qPrintable(version_qstring()));
    return 0;
  }

  qmlRegisterType<FEAnalyzer>("rustgolem", 1, 0, "FEAnalyzer");

/*
  qmlRegisterType<SoftwareUpdater>("rustgolem", 1, 0, "SoftwareUpdater");
  qmlRegisterType<Messenger>("rustgolem", 1, 0, "Messenger");
*/
  QQmlApplicationEngine engine(QUrl("qrc:/qml/MainWindow.qml"));
  return app.exec();
}
