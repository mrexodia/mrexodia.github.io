#include "keygen.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    KeyGen w;
    w.show();

    return a.exec();
}
