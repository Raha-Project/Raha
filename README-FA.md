# پروژه رها

[English](README.md)

پروژه رها یک مجموعه میکروسرویس برای استفاده راحت از قدرتمند ترین پلتفرم های ضد سانسور اینترنت است.

این مجموعه شامل بخش های زیر است
1. بخش [Raha-Xray](https://github.com/Raha-Project/raha-xray) : یک سرویس API ساده برای استفاده از [xray-core](https://github.com/XTLS/Xray-core)
2. بخش `Raha-*` : رزرو شده برای سرویس های API دیگر
3. بخش `Raha-Panel` (به زودی) : یک پنل وب مولتی سرور برای کنترل همه API ها
4. بخش [Raha-Docs](https://github.com/Raha-Project/raha-docs) (موقت) : راهنمای موقت  برای همه بخش های پروژه
5. سایت [Raha-Project.github.io](https://raha-project.github.io) (به زودی) : وب سایت راهنما

## نرم افزار Raha-Xray
* این نرم افزار برای کنترل و تنظیم `xray-core` برای همه نیازهای شما طراحی شده و خروجی آن API است.
* شما میتوانید این بخش رو در چندین سرور نصب کنید و از طریق یک نرم افزار یا پنل وب همه آنها رو کنترل کنید.
* این نرم افزار برای استفاده ساده از پایگاه داده `SQLite` استفاده میکند و میتواند برای استفاده از `MySQL` برای استفاده پیشرفته تنظیم شود.

### روش های نصب

شما میتوانید از لینک های زیر برای نصب و یا بروزرسانی این نرم افزار روی سرور خود استفاده کنید

#### 1. نصب `raha-xray` با پایگاه داده `SQLite`

```sh
bash <(curl -Ls https://raw.githubusercontent.com/Raha-Project/Raha/master/install.sh)
```

#### 2. نصب `raha-xray` با پایگاه داده `MySQL`

```sh
bash <(curl -Ls https://raw.githubusercontent.com/Raha-Project/Raha/master/linuxMySQL/install.sh)
```

#### 3. نصب `raha-xray` + `MySQL` توسط داکر (برای تست توصیه میشود)

```sh
bash <(curl -Ls https://raw.githubusercontent.com/Raha-Project/Raha/master/dockerMysql/install.sh)
```
