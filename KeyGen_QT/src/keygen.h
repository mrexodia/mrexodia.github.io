#ifndef KEYGEN_H
#define KEYGEN_H

#include <QMainWindow>
#include <QString>

namespace Ui {
class KeyGen;
}

class KeyGen : public QMainWindow
{
    Q_OBJECT

public:
    explicit KeyGen(QWidget *parent = 0);
    ~KeyGen();

private slots:
    void on_pushButton_clicked();
    QByteArray CreateXorSum(QByteArray);

private:
    Ui::KeyGen *ui;
};

#endif // KEYGEN_H
