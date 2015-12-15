#include "keygen.h"
#include "ui_keygen.h"
#include <QDebug>

KeyGen::KeyGen(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::KeyGen)
{
    ui->setupUi(this);
}

KeyGen::~KeyGen()
{
    delete ui;
}

QByteArray KeyGen::CreateXorSum(QByteArray baInput)
{
    QByteArray uchRtnVal = "\x0";
    for(int i = 0; i < baInput.length(); i++)
        uchRtnVal[0] = uchRtnVal[0] ^ baInput[i];

    return uchRtnVal;
}

void KeyGen::on_pushButton_clicked()
{
    QString qsOutText;
    QByteArray baRslt = "\x2B\xE8\x62\xA7";
    QByteArray baName = ui->txtName->text().toUtf8();
    int cnt = 0;

    for(int i = 0; i < baName.length(); i++)
    {
        if(cnt > 3)
            cnt = 0;
        baRslt[cnt] = baRslt[cnt] ^ (baName[i] ^ 0xFF);
        cnt++;
    }
    baRslt.insert(0,CreateXorSum(baRslt));
    qsOutText = baRslt.toHex().toUpper();
    ui->txtCode->setText(qsOutText);
}
