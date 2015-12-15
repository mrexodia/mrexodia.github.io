/********************************************************************************
** Form generated from reading UI file 'keygen.ui'
**
** Created by: Qt User Interface Compiler version 5.4.2
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_KEYGEN_H
#define UI_KEYGEN_H

#include <QtCore/QVariant>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QMenuBar>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QStatusBar>
#include <QtWidgets/QToolBar>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_KeyGen
{
public:
    QWidget *centralWidget;
    QPushButton *pushButton;
    QLineEdit *txtName;
    QLineEdit *txtCode;
    QLabel *label;
    QLabel *label_2;
    QMenuBar *menuBar;
    QToolBar *mainToolBar;
    QStatusBar *statusBar;

    void setupUi(QMainWindow *KeyGen)
    {
        if (KeyGen->objectName().isEmpty())
            KeyGen->setObjectName(QStringLiteral("KeyGen"));
        KeyGen->resize(342, 164);
        centralWidget = new QWidget(KeyGen);
        centralWidget->setObjectName(QStringLiteral("centralWidget"));
        pushButton = new QPushButton(centralWidget);
        pushButton->setObjectName(QStringLiteral("pushButton"));
        pushButton->setGeometry(QRect(50, 80, 75, 23));
        pushButton->setAutoDefault(false);
        pushButton->setDefault(true);
        txtName = new QLineEdit(centralWidget);
        txtName->setObjectName(QStringLiteral("txtName"));
        txtName->setGeometry(QRect(50, 20, 221, 20));
        txtCode = new QLineEdit(centralWidget);
        txtCode->setObjectName(QStringLiteral("txtCode"));
        txtCode->setGeometry(QRect(50, 50, 221, 20));
        label = new QLabel(centralWidget);
        label->setObjectName(QStringLiteral("label"));
        label->setGeometry(QRect(10, 20, 47, 13));
        label_2 = new QLabel(centralWidget);
        label_2->setObjectName(QStringLiteral("label_2"));
        label_2->setGeometry(QRect(10, 50, 41, 16));
        KeyGen->setCentralWidget(centralWidget);
        menuBar = new QMenuBar(KeyGen);
        menuBar->setObjectName(QStringLiteral("menuBar"));
        menuBar->setGeometry(QRect(0, 0, 342, 21));
        KeyGen->setMenuBar(menuBar);
        mainToolBar = new QToolBar(KeyGen);
        mainToolBar->setObjectName(QStringLiteral("mainToolBar"));
        KeyGen->addToolBar(Qt::TopToolBarArea, mainToolBar);
        statusBar = new QStatusBar(KeyGen);
        statusBar->setObjectName(QStringLiteral("statusBar"));
        KeyGen->setStatusBar(statusBar);
        QWidget::setTabOrder(txtName, txtCode);
        QWidget::setTabOrder(txtCode, pushButton);

        retranslateUi(KeyGen);

        QMetaObject::connectSlotsByName(KeyGen);
    } // setupUi

    void retranslateUi(QMainWindow *KeyGen)
    {
        KeyGen->setWindowTitle(QApplication::translate("KeyGen", "KeyGen", 0));
        pushButton->setText(QApplication::translate("KeyGen", "Get Code", 0));
        label->setText(QApplication::translate("KeyGen", "Name:", 0));
        label_2->setText(QApplication::translate("KeyGen", "Code:", 0));
    } // retranslateUi

};

namespace Ui {
    class KeyGen: public Ui_KeyGen {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_KEYGEN_H
