-- Active: 1762503231714@@127.0.0.1@3306@mysql
# 주석
-- 주석 
/* 
    여러줄 주석
*/
# SQL은 대소문자를 구분하지 않는다. 단, 데이터 대소문자는 구분한다.

# 사용자 생성
# - 어디에서나 접속가능한(%) skn22 계정(비밀번호 skn22)
create user 'skn22'@'%' identified by 'skn22';

# 데이터베이스 확인
show databases;
# 데이터베이스 선택
use mysql;
select * from user;

# 데이터베이스(스키마) 생성
create database menudb;

# 사용자에게 데이터베이스 사용권한 부여
grant all privileges on menudb.* to 'skn22'@'%';
-- revoke al PRIVILEGES on menudb.* from 'skn22'@'%';

# 실습문제용 db생성
create database empdb;
grant all privileges on empdb.* to 'skn22'@'%';

# 기본실습용 db생성
create database basicdb; -- schema = database
grant all privileges on basicdb.* to 'skn22'@'%'; 