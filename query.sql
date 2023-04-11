SET SESSION sql_mode=(SElecT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
-- drop database portfolio;
create database portfolio;
use portfolio;


-- For debugging
-- drop table company_profile;
-- drop table company_price;
-- drop table fundamental_report;
-- drop table technical_signals;
-- drop table dividend_history;
-- drop table news;
-- drop table user_profile;
-- drop table watchlist;
-- drop table transaction_history;


create table financial_info
(
todays_date date UNIQUE NOT NULL,
interest_rate float,
inflation_rate float,
gdp_growth float,
primary key(todays_date)
);

create table user_profile
(
username varchar(30),
email varchar(60) UNIQUE NOT NULL,
user_password varchar(224),
primary key(username)
);


create table company_profile
(
symbol varchar(10),
company_name varchar(100) NOT NULL,
sector varchar(20) NOT NULL,
market_cap bigint NOT NULL,
paidup_capital bigint NOT NULL,
primary key(symbol)
);

create table transaction_history
(
transaction_id int auto_increment,
username varchar(30) NOT NULL,
symbol varchar(10) NOT NULL,
transaction_date datetime NOT NULL,
quantity int NOT NULL,
rate float NOT NULL,
primary key(transaction_id),
foreign key(symbol) references company_profile(symbol),
foreign key(username) references user_profile(username)
);


create table performance_metrics(
transaction_id int,
total_return float,
annualized_return float,
risk_level float,
primary key(transaction_id),
foreign key(transaction_id) references transaction_history(transaction_id)
);

create table company_price
(
symbol varchar(10),
LTP float NOT NULL,
PC float NOT NULL,
primary key(symbol),
foreign key(symbol) references company_profile(symbol)
);

create table historical_data
(
date date,
symbol varchar(10),
LTP float NOT NULL,
PC float NOT NULL,
primary key(date,symbol),
foreign key(symbol) references company_profile(symbol)
);


create table fundamental_report
(
symbol varchar(10),
report_as_of varchar(10),
EPS float NOT NULL,
ROE float NOT NULL,
book_value float NOT NULL,
primary key (symbol, report_as_of),
foreign key (symbol) references company_profile(symbol)
);

create table technical_signals
(
symbol varchar(10),
LTP float,
RSI float NOT NULL,
volume float NOT NULL,
ADX float NOT NULL,
MACD varchar(4) NOT NULL,
primary key (symbol),
foreign key (symbol) references company_profile(symbol)
);


create table news
(
news_id int auto_increment,
title varchar(200) NOT NULL,
date_of_news date NOT NULL,
related_company varchar(10),
sources varchar(20),
primary key(news_id, sources),
foreign key(related_company) references company_profile(symbol)
);



create table  watchlist
(
username varchar(30),
symbol varchar(10),
primary key(username, symbol),
foreign key(username) references user_profile(username),
foreign key(symbol) references company_profile(symbol)
);


-- Data entry

insert into user_profile values
('raunak', 'uni.momo@gmail.com', sha2('raunak123', 224)),
('mahesh', 'uni@gmail.com',  sha2('araunak123', 224)),
('dimple', 'uni1.momo@gmail.com', sha2('raunak12345', 224)),
('madhu', 'uni2.momo@gmail.com', sha2('araunak123', 224)),
('sobit', 'uni3.momo@gmail.com', sha2('braunak123', 224)),
('ray', 'uni4.momo@gmail.com', sha2('craunak123', 224)),
('momo', 'uni5.momo@gmail.com', sha2('draunak123', 224)),
('ravi', 'uni6.momo@gmail.com',sha2('eraunak123', 224)),
('michael', 'uni7.momo@gmail.com', sha2('fraunak123', 224)),
('hari', 'uni8.momo@gmail.com', sha2('araunak123', 224)),
('madan', 'uni10.momo@gmail.com', sha2('rfewan123', 224)),
('sandeep', 'uni11.momo@gmail.com', sha2('fraunak123', 224)),
('surya', 'tha0751@gmail.com', sha2('araunak123', 224)),
('vai', 'tha0752@gmail.com', sha2('wraunak123', 224)),
('gtm', 'tha075@gmail.com', sha2('eraunak123', 224));

insert into financial_info values
('2023-04-01',6.5,5.6, 6.4),
('2023-04-02',6.5,5.6, 6.4),
('2023-04-03',6.5,5.6, 6.4),
('2023-04-04',6.5,5.6, 6.4),
('2023-04-05',6.5,5.6, 6.4),
('2023-04-06',6.5,5.6, 6.4),
('2023-04-07',6.5,5.6, 6.4),
('2023-04-08',6.5,5.6, 6.4),
('2023-04-09',6.5,5.6, 6.4),
('2023-04-10',6.5,5.6, 6.4);



insert into company_profile values
('SBI', 'State Stock of India', 'Stock', 1000000000, 21212121221),
('PNG', 'Punjab National Stock', 'Stock', 123232332, 131321321),
('HDFC', 'HOUSING DEVELOPMENT FINANCE CORPORATION LIMITED', 'Stock', 63233232, 61321321),
('AXISB', 'Axis Bank', 'Stock', 32323233232, 323321321321),
('GC', 'Gold', 'Commodity', 102323233232, 10323321321321),
('SI', 'Silver', 'Commodity', 23233232, 21321321),
('PL', 'Platinum', 'Commodity', 532323233232, 5323321321321),
('GBP/USD', 'British Pound/US Dollars', 'Currency', 82323233232, 823321321321),
('USD/JPY', 'US Dollars/Japanese Yen', 'Currency', 12323233232, 123321321321),
('EUR/USD', 'Euro/US Dollars', 'Currency', 62323233232, 623321321321);

insert into company_price (symbol, LTP, PC) values
('SBI', 500, 470),
('PNG', 5800, 6000),
('HDFC', 400, 410),
('AXISB', 1010, 1000),
('GC', 500, 480),
('SI', 1000, 1040),
('PL', 600, 580.5),
('GBP/USD', 1222.3, 1220),
('USD/JPY', 1500.5, 1499.4),
('EUR/USD', 788, 777);


insert into historical_data (date, symbol, LTP, PC) values
('2023-04-01','SBI', 500, 470),
('2023-04-02','SBI', 600, 470),
('2023-04-03','SBI', 400, 470),
('2023-04-04','SBI', 300, 470),
('2023-04-05','SBI', 200, 470),
('2023-04-06','SBI', 5100, 470),
('2023-04-07','SBI', 50, 470),
('2023-04-08','SBI', 100, 470),
('2023-04-09','SBI', 280, 470),
('2023-04-10','SBI', 590, 470),
('2023-04-01','PNG', 5700, 6000),
('2023-04-02','PNG', 5600, 6000),
('2023-04-03','PNG', 5500, 6000),
('2023-04-04','PNG', 5400, 6000),
('2023-04-05','PNG', 5300, 6000),
('2023-04-06','PNG', 5200, 6000),
('2023-04-07','PNG', 5800, 6000),
('2023-04-08','PNG', 5100, 6000),
('2023-04-09','PNG', 5800, 6000),
('2023-04-10','PNG', 5900, 6000),
('2023-04-01','HDFC', 420, 410),
('2023-04-02','HDFC', 410, 410),
('2023-04-03','HDFC', 450, 410),
('2023-04-04','HDFC', 460, 410),
('2023-04-05','HDFC', 470, 410),
('2023-04-06','HDFC', 430, 410),
('2023-04-07','HDFC', 480, 410),
('2023-04-08','HDFC', 480, 410),
('2023-04-09','HDFC', 490, 410),
('2023-04-10','HDFC', 403, 410),
('2023-04-01','AXISB', 1010, 1000),
('2023-04-02','AXISB', 1012, 1000),
('2023-04-03','AXISB', 1015, 1000),
('2023-04-04','AXISB', 1018, 1000),
('2023-04-05','AXISB', 1013, 1000),
('2023-04-06','AXISB', 1016, 1000),
('2023-04-07','AXISB', 1016, 1000),
('2023-04-08','AXISB', 1018, 1000),
('2023-04-09','AXISB', 1013, 1000),
('2023-04-10','AXISB', 1010, 1000),
('2023-04-01','GC', 500, 480),
('2023-04-02','GC', 600, 480),
('2023-04-03','GC', 700, 480),
('2023-04-04','GC', 600, 480),
('2023-04-05','GC', 300, 480),
('2023-04-06','GC', 200, 480),
('2023-04-07','GC', 900, 480),
('2023-04-08','GC', 100, 480),
('2023-04-09','GC', 700, 480),
('2023-04-10','GC', 900, 480),
('2023-04-01','SI', 1000, 1040),
('2023-04-02','SI', 1001, 1040),
('2023-04-03','SI', 1002, 1040),
('2023-04-04','SI', 1003, 1040),
('2023-04-05','SI', 1004, 1040),
('2023-04-06','SI', 1005, 1040),
('2023-04-07','SI', 1006, 1040),
('2023-04-08','SI', 1007, 1040),
('2023-04-09','SI', 1008, 1040),
('2023-04-10','SI', 1009, 1040),
('2023-04-01','PL', 600, 580.5),
('2023-04-02','PL', 611, 580.5),
('2023-04-03','PL', 602, 580.5),
('2023-04-04','PL', 603, 580.5),
('2023-04-05','PL', 604, 580.5),
('2023-04-06','PL', 605, 580.5),
('2023-04-07','PL', 606, 580.5),
('2023-04-08','PL', 607, 580.5),
('2023-04-09','PL', 608, 580.5),
('2023-04-10','PL', 609, 580.5),
('2023-04-01','GBP/USD', 1232.3, 1220),
('2023-04-02','GBP/USD', 1212.3, 1220),
('2023-04-03','GBP/USD', 1222.3, 1220),
('2023-04-04','GBP/USD', 1242.3, 1220),
('2023-04-05','GBP/USD', 1252.3, 1220),
('2023-04-06','GBP/USD', 1262.3, 1220),
('2023-04-07','GBP/USD', 1272.3, 1220),
('2023-04-08','GBP/USD', 1282.3, 1220),
('2023-04-09','GBP/USD', 1292.3, 1220),
('2023-04-10','GBP/USD', 1202.3, 1220),
('2023-04-01','USD/JPY', 1501.5, 1499.4),
('2023-04-02','USD/JPY', 1502.5, 1499.4),
('2023-04-03','USD/JPY', 1500.5, 1499.4),
('2023-04-04','USD/JPY', 1504.5, 1499.4),
('2023-04-05','USD/JPY', 1500.5, 1499.4),
('2023-04-06','USD/JPY', 1505.5, 1499.4),
('2023-04-07','USD/JPY', 1506.5, 1499.4),
('2023-04-08','USD/JPY', 1507.5, 1499.4),
('2023-04-09','USD/JPY', 1507.5, 1499.4),
('2023-04-10','USD/JPY', 1505.5, 1499.4),
('2023-04-01','EUR/USD', 798, 777),
('2023-04-02','EUR/USD', 728, 777),
('2023-04-03','EUR/USD', 728, 777),
('2023-04-04','EUR/USD', 738, 777),
('2023-04-05','EUR/USD', 748, 777),
('2023-04-06','EUR/USD', 758, 777),
('2023-04-07','EUR/USD', 768, 777),
('2023-04-08','EUR/USD', 778, 777),
('2023-04-09','EUR/USD', 748, 777),
('2023-04-10','EUR/USD', 738, 777);


insert into fundamental_report(symbol, report_as_of, EPS, ROE, book_value) values
('SBI', '77/78_q3', 20.5, 11.97, 120),
('SBI', '77/78_q2', 19.5, 10, 110),  
('PNG', '77/78_q3', 205, 50, 300),
('PNG', '77/78_q2', 211, 55, 310),
('HDFC', '77/78_q3', 8, 4, 90),
('HDFC', '77/78_q2', 7.5, 3.5, 88),
('AXISB', '77/78_q3', 34, 15, 180),
('AXISB', '77/78_q2', 31, 13, 178),
('GC', '77/78_q3', 21, 12, 119),
('GC', '77/78_q2', 20, 11, 118),
('SI', '77/78_q3', 30, 12, 170),
('SI', '77/78_q2', 35.4, 13, 180.5),
('PL', '77/78_q3', 22, 13, 120),
('PL', '77/78_q2', 21, 12, 117),
('GBP/USD', '77/78_q3', 50, 15, 200),
('GBP/USD', '77/78_q2', 48, 14, 199),
('USD/JPY', '77/78_q3', 60, 20, 220),
('USD/JPY', '77/78_q2', 55, 18, 200),
('EUR/USD', '77/78_q3', 36, 20, 220),
('EUR/USD', '77/78_q2', 35, 21, 200);

insert into technical_signals(symbol, RSI, volume, ADX, MACD) values 
('SBI', 65.1, 451000, 33.3, 'bull'), 
('PNG', 50.5, 100000, 40, 'bull'), 
('HDFC', 20, 12344, 15, 'bear'),
('AXISB', 70, 1200000, 30, 'bull'),
('GC', 45, 212000, 16.5, 'bull'),
('SI', 53.4, 15312, 25.29, 'bull'),
('PL', 66.41, 406121, 34.66, 'bull'),
('GBP/USD', 40.2, 34000, 40, 'side'),
('USD/JPY', 35, 120000, 30, 'side'),
('EUR/USD', 75, 335000, 44, 'bull');

-- Updating LTP values in technical_signals
UPDATE technical_signals A
INNER JOIN company_price B ON A.symbol = B.symbol
SET A.LTP = B.LTP
WHERE A.symbol = B.symbol;



insert into watchlist values
('raunak', 'SBI'),
('raunak', 'GBP/USD'),
('raunak', 'USD/JPY'),
('raunak', 'EUR/USD'),
('mahesh', 'GBP/USD'),
('mahesh', 'AXISB'),
('mahesh', 'HDFC'),
('dimple', 'GC'),
('dimple', 'SI'),
('madhu', 'AXISB'),
('madhu', 'GBP/USD'),
('madhu', 'PL'),
('sobit', 'GBP/USD'),
('sobit', 'HDFC'),
('momo','USD/JPY');

insert into news(news_id, title, sources, date_of_news, related_company) values
(1, 'State Bank of India announces right share of 1:1', 'myRepublica', '2021-07-01', 'SBI'),
(2, 'HDFC to change its employees soon', 'Hindustan Times', '2021-07-04', 'HDFC'),
(3, 'Currency USD falls by 3%', 'USnews', '2021-07-05', 'USD/JPY'),
(4, 'CEO of Punjab National Bank resigns immediately', 'Economic Times', '2021-07-10', 'PNG'),
(5, 'Gold prices expected to rise by next year', 'Economic Times', '2021-07-10', 'PNG');


insert into transaction_history(username, symbol, transaction_date, quantity, rate) values
('raunak', 'GBP/USD', '2021-07-01', 110, 1201),
('raunak', 'USD/JPY', '2021-07-02', 55, 1480),
('raunak', 'USD/JPY', '2021-07-06', -20, 1500),
('dimple', 'HDFC', '2021-07-10', 10, 420),
('dimple', 'HDFC', '2021-07-15', 10, 410),
('raunak', 'EUR/USD', '2021-07-20', 120, 785.5),
('raunak', 'SI', '2021-07-20', 55, 1001),
('raunak', 'GBP/USD', '2021-07-01', 100, 1200),
('raunak', 'USD/JPY', '2021-07-02', 55, 1480),
('raunak', 'USD/JPY', '2021-07-06', -20, 1500);


insert into performance_metrics(transaction_id,total_return, annualized_return, risk_level) values
(1,((((SElecT rate from transaction_history where transaction_id = 1) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=1)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=1)))*100,
if(((((SElecT rate from transaction_history where transaction_id = 1) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=1)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=1)))*100>0,(power(1+(((SElecT rate from transaction_history where transaction_id = 1) -(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=1))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=1))*100,365/(datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=1))))-1)*100,0),
(select stddev(LTP) from historical_data where symbol = (SElecT symbol from transaction_history where transaction_id=1))),
(2,((((SElecT rate from transaction_history where transaction_id = 2) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=2)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=2)))*100,
if(((((SElecT rate from transaction_history where transaction_id = 2) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=2)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=2)))*100>0,(power(1+(((SElecT rate from transaction_history where transaction_id = 2) -(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=2))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=2))*100,365/(datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=2))))-1)*100,0),
(select stddev(LTP) from historical_data where symbol = (SElecT symbol from transaction_history where transaction_id=2))),
(3,((((SElecT rate from transaction_history where transaction_id = 3) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=3)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=3)))*100,
if(((((SElecT rate from transaction_history where transaction_id = 3) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=3)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=3)))*100>0,(power(1+(((SElecT rate from transaction_history where transaction_id = 3) -(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=3))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=3))*100,365/(datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=3))))-1)*100,0),
(select stddev(LTP) from historical_data where symbol = (SElecT symbol from transaction_history where transaction_id=3))),
(4,((((SElecT rate from transaction_history where transaction_id = 4) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=4)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=4)))*100,
if(((((SElecT rate from transaction_history where transaction_id = 4) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=4)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=4)))*100>0,(power(1+(((SElecT rate from transaction_history where transaction_id = 4) -(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=4))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=4))*100,365/(datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=4))))-1)*100,0),
(select stddev(LTP) from historical_data where symbol = (SElecT symbol from transaction_history where transaction_id=4))),
(5,((((SElecT rate from transaction_history where transaction_id = 5) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=5)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=5)))*100,
if(((((SElecT rate from transaction_history where transaction_id = 5) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=5)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=5)))*100>0,(power(1+(((SElecT rate from transaction_history where transaction_id = 5) -(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=5))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=5))*100,365/(datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=5))))-1)*100,0),
(select stddev(LTP) from historical_data where symbol = (SElecT symbol from transaction_history where transaction_id=5))),
(6,((((SElecT rate from transaction_history where transaction_id = 6) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=6)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=6)))*100,
if(((((SElecT rate from transaction_history where transaction_id = 6) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=6)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=6)))*100>0,(power(1+(((SElecT rate from transaction_history where transaction_id = 6) -(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=6))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=6))*100,365/(datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=6))))-1)*100,0),
(select stddev(LTP) from historical_data where symbol = (SElecT symbol from transaction_history where transaction_id=6))),
(7,((((SElecT rate from transaction_history where transaction_id = 7) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=7)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=7)))*100,
if(((((SElecT rate from transaction_history where transaction_id = 7) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=7)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=7)))*100>0,(power(1+(((SElecT rate from transaction_history where transaction_id = 7) -(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=7))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=7))*100,365/(datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=7))))-1)*100,0),
(select stddev(LTP) from historical_data where symbol = (SElecT symbol from transaction_history where transaction_id=7))),
(8,((((SElecT rate from transaction_history where transaction_id = 8) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=8)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=8)))*100,
if(((((SElecT rate from transaction_history where transaction_id = 8) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=8)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=8)))*100>0,(power(1+(((SElecT rate from transaction_history where transaction_id = 8) -(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=8))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=8))*100,365/(datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=8))))-1)*100,0),
(select stddev(LTP) from historical_data where symbol = (SElecT symbol from transaction_history where transaction_id=8))),
(9,((((SElecT rate from transaction_history where transaction_id = 9) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=9)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=9)))*100,
if(((((SElecT rate from transaction_history where transaction_id = 9) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=9)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=9)))*100>0,(power(1+(((SElecT rate from transaction_history where transaction_id = 9) -(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=9))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=9))*100,365/(datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=9))))-1)*100,0),
(select stddev(LTP) from historical_data where symbol = (SElecT symbol from transaction_history where transaction_id=9))),
(10,((((SElecT rate from transaction_history where transaction_id = 10) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=10)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=10)))*100,
if(((((SElecT rate from transaction_history where transaction_id = 10) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=10)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=10)))*100>0,(power(1+(((SElecT rate from transaction_history where transaction_id = 10) -(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=10))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=10))*100,365/(datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=10))))-1)*100,0),
(select stddev(LTP) from historical_data where symbol = (SElecT symbol from transaction_history where transaction_id=10)));


-- Holdings

Create view holdings_view as
select username, symbol, sum(quantity) as quantity  from transaction_history
group by username, symbol;

-- Holdings with LTP and current value for user raunak

-- select A.symbol, A.quantity, B.LTP, round(A.quantity*B.LTP, 2) as current_value from holdings_view A
-- inner join company_price B
-- on A.symbol = B.symbol
-- where username = 'raunak';

-- Fundamental report 

Create view fundamental_averaged as
SElecT F.symbol, LTP, round(avg(EPS), 2) as EPS, round(avg(ROE), 2) as ROE, 
round(avg(book_value), 2) AS book_value, round(avg(LTP/EPS), 2) AS pe_ratio 
FROM fundamental_report F
INNER JOIN company_price C
on F.symbol = C.symbol
group by(Symbol);


-- select * from  fundamental_averaged;

-- Fundamental report of certain company without averaging

-- select F.symbol, report_as_of, LTP, eps, roe, book_value, round(LTP/eps, 2) as pe_ratio
-- from fundamental_report F
-- inner join company_price C
-- on F.symbol = C.symbol
-- where F.symbol = 'EUR/USD';

-- Technical report

-- select A.symbol, sector, LTP, volume, RSI, ADX, MACD from technical_signals A 
-- left join company_profile B
-- on A.symbol = B.symbol
-- order by (A.symbol);

-- Company profile

-- select * from company_profile
-- order by(symbol);

-- Company price

-- SElecT symbol, LTP, PC, round((LTP-PC), 2) as CH, round(((LTP-PC)/PC)*100, 2) AS CH_percent FROM company_price
-- order by symbol;



-- Portfolio system 

-- Certain user portfolio

-- select *
-- from holdings_view A
-- left outer join company_price B on A.symbol = B.symbol
-- left outer join fundamental_averaged F on A.symbol = F.symbol
-- left outer join technical_signals T on A.symbol = T.symbol
-- where username = 'raunak'
-- order by (A.symbol);	

-- Fundamentally strong

-- select A.symbol from holdings_view A 
-- left outer join fundamental_report F on A.symbol = F.symbol
-- where username = 'raunak'
-- group by(symbol);

-- Best companies to invest

-- select * from company_price
-- natural join fundamental_averaged
-- natural join technical_signals
-- natural join company_profile 
-- where 
-- EPS>25 and roe>13 and 
-- book_value > 100 and
-- rsi>50 and adx >23 and
-- pe_ratio < 35 and
-- macd = 'bull'
-- order by symbol;

-- EPS more than 30

-- select * from fundamental_averaged
-- where eps > 30;

-- PE Ratio less than 30

-- select * from fundamental_averaged
-- where pe_ratio <30;

-- Technically

-- select * from technical_signals
-- where ADX > 23 and rsi>50 and rsi<70 and MACD = 'bull';

-- Total profit or loss


-- select username, A.symbol, sum(quantity) as quantity, sum(rate) as total, round(sum(rate)/sum(quantity), 2) as updated_rate,
-- B.LTP, round((B.LTP * sum(quantity) - sum(rate)), 2) as profit_loss  
-- from transaction_history A left outer join company_price B
-- on A.symbol = B.symbol
-- group by A.username, A.symbol;


-- Watchlist

-- select symbol, LTP, PC, round((LTP-PC), 2) AS CH, round(((LTP-PC)/PC)*100, 2) AS CH_percent from watchlist
-- natural join company_price
-- where username = 'dimple'
-- order by (symbol);

-- For drop down watchlist addition

-- SElecT symbol from company_profile
-- where symbol not in
-- (select symbol from watchlist
-- where username = 'raunak');

-- News

-- select date_of_news, title, related_company, C.sector, group_concat(sources) as sources 
-- from news N
-- inner join company_profile C
-- on N.related_company = C.symbol
-- group by(title);

-- For pie chart (sector with total values)

-- select C.sector, sum(A.quantity*B.LTP) as current_value 
-- from holdings_view A
-- inner join company_price B
-- on A.symbol = B.symbol
-- inner join company_profile C
-- on A.symbol = C.symbol
-- where username = 'raunak'
-- group by C.sector;


-- Profit loss in portfolio

-- Function to find total amount (amount + broker commission + sebon fee + DP charge) excluding capital gain tax
DELIMITER $$
CREATE FUNCTION getTotal(
	total float
) 
RETURNS float
DETERMINISTIC
BEGIN
	DECLARE total_converted float;
    DECLARE comm float;
    DECLARE ptotal float;
    
    -- If sell, make the total positive to calculate commission later
    IF total<0 THEN
		SET ptotal = -total;
	ELSE 
		SET ptotal = total;
	END IF;
	
    -- Commission is same for both buy and sell
    IF ptotal > 500000 THEN
		SET comm = (0.34/100)*ptotal;
	ELSEIF ptotal > 50000 THEN
		SET comm = (0.37/100)*ptotal;
	ELSEIF ptotal > 2500 THEN
		SET comm = (0.4/100)*ptotal;
	ELSEIF ptotal > 100 THEN
		SET comm =  10;
	END IF;
    
    -- If sell conditions
	IF total < 0 THEN
		set total = -total;
		set total_converted = total - (comm + total*(0.015/100) + 25);
        RETURN total_converted;
    END IF;
    
	SET total_converted = total + comm + 25 + (0.015/100)*total;
	RETURN (total_converted);
END$$
DELIMITER ;


-- drop function getTotal;

-- Function to find profit loss with capital gain tax deducted

DELIMITER $$
CREATE FUNCTION capGain(
	total float,
    trans_date date
) 
RETURNS float
DETERMINISTIC
BEGIN
    IF total<0 THEN
		RETURN total;
	ELSEIF datediff(Now(), trans_date)<365 THEN
		SET total = total - 0.075*total;
	ELSE 
		SET total = total - 0.05*total;
	END IF;
	RETURN total;
END$$
DELIMITER ;

-- drop function capGain;


-- Profit loss summary

-- select symbol, sum(quantity) as quantity, LTP, rate,
-- capGain(round((getTotal(-sum(quantity)*LTP)) - (getTotal(sum(quantity)*rate)), 2), transaction_date) as profit_loss
-- from transaction_history T
-- natural join company_price C
-- where username = 'raunak'
-- group by symbol;

-- select * from transaction_history
-- natural join company_price
-- where username='raunak'
-- group by symbol;


-- Stored procedure for portfolio (holdings with profit/loss)

DELIMITER $$
CREATE PROCEDURE portfolio(in username varchar(30))
BEGIN
select symbol, sum(quantity) as quantity, LTP
,round((getTotal(-sum(quantity)*LTP)), 2) as current_value,
capGain(round((getTotal(-sum(quantity)*LTP)) - (getTotal(sum(quantity*rate))), 2), transaction_date) as profit_loss
from transaction_history T
natural join company_price C
where username = username
group by symbol;
END$$
DELIMITER ;

-- SElecT @@sql_mode;
-- SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
-- SET SESSION sql_mode=(SElecT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- call portfolio('raunak');
-- select * from user_profile;
-- describe user_profile;


-- Q1

-- create table transaction_history
-- (
-- transaction_id int auto_increment,
-- username varchar(30) NOT NULL,
-- symbol varchar(6) NOT NULL,
-- transaction_date datetime NOT NULL,
-- quantity int NOT NULL,
-- rate float NOT NULL,
-- primary key(transaction_id),
-- foreign key(symbol) references company_profile(symbol),
-- foreign key(username) references user_profile(username)
-- );

-- Q2

-- create table performance_metrics(
-- transaction_id int auto_increment,
-- total_return float,
-- annualized_return float,
-- risk_level float,
-- primary key(transaction_id),
-- foreign key(transaction_id) references transaction_history(transaction_id)
-- );

-- Q3

-- create table historical_data
-- (
-- date date,
-- symbol varchar(6),
-- LTP float NOT NULL,
-- PC float NOT NULL,
-- primary key(date,symbol),
-- foreign key(symbol) references company_profile(symbol)
-- );

-- Q4

-- create table financial_info
-- (
-- todays_date date UNIQUE NOT NULL,
-- interest_rate float,
-- inflation_rate float,
-- gdp_growth float,
-- primary key(todays_date)
-- );

-- Q5

-- insert into transaction_history(username, symbol, transaction_date, quantity, rate) values
-- ('raunak', 'GBP/USD', '2021-07-01', 110, 1201);

-- Q6

-- update transaction_history set quantity = 50 where transaction_id = 1;

-- Q7

-- delete from transaction_history where transaction_id = 1;

-- Q8

--  SElecT company_name, transaction_id,total_return from company_profile NATURAL JOIN performance_metrics NATURAL JOIN transaction_history;

-- Q9

--  SElecT company_name, date,LTP from company_profile NATURAL JOIN historical_data where date = '2023-04-05';

-- Q10

-- SElecT transaction_id, sector, avg(annualized_return) from company_profile NATURAL JOIN performance_metrics NATURAL JOIN transaction_history group by sector;

-- Q11

-- SElecT transaction_id, company_name, risk_level from company_profile NATURAL JOIN transaction_history NATURAL JOIN performance_metrics order by risk_level LIMIT 5;

-- Q12

-- SElecT transaction_id, company_name, quantity*(SElecT LTP from historical_data B where date = '2023-04-10' AND B.symbol = A.symbol) as total_value from transaction_history NATURAL JOIN company_profile A order by transaction_id; 

-- Q13

-- SElecT( (SElecT sum(annualized_return*quantity) from performance_metrics NATURAL JOIN transaction_history) / (SElecT sum(quantity) from transaction_history)) as Annual_return_of_portfolio;

-- Q14


-- SElecT((SElecT avg(A - (SElecT Avg(A) from (SElecT C.LTP as A, D.LTP as B from historical_data C, historical_data D where C.symbol = (SElecT symbol as symA from transaction_history where transaction_id = 2) AND D.symbol = (SElecT symbol as symB from transaction_history where transaction_id = 4 AND C.date = D.date)) as new_tab))
-- * avg(B - (SElecT avg(B) from (SElecT C.LTP as A, D.LTP as B from historical_data C, historical_data D where C.symbol = (SElecT symbol as symA from transaction_history where transaction_id = 2) AND D.symbol = (SElecT symbol as symB from transaction_history where transaction_id = 4 AND C.date = D.date)) as new_tab)) from (SElecT C.LTP as A, D.LTP as B from historical_data C, historical_data D where C.symbol = (SElecT symbol as symA from transaction_history where transaction_id = 2) AND D.symbol = (SElecT symbol as symB from transaction_history where transaction_id = 4 AND C.date = D.date)) as new_tab) / (SElecT risk_level from performance_metrics where transaction_id = 2)*(SElecT risk_level from performance_metrics where transaction_id = 4)) as correlation;


-- Q15

-- SElecT todays_date, inflation_rate from financial_info order by -todays_date LIMIT 1;

-- Q16

-- SElecT B.date,A.transaction_id, C.company_name, B.LTP from (transaction_history A NATURAL JOIN company_profile C) INNER JOIN historical_data B ON A.symbol = B.symbol AND date between '2023-04-02' AND '2023-04-08' AND A.transaction_id = 4 order by B.date, A.transaction_id;


-- Q17

-- SElecT transaction_id, company_name, (((SElecT LTP from historical_data B where date = '2023-04-08' and B.symbol = A.symbol) -(SElecT LTP from historical_data B where date = '2023-04-02' and B.symbol = A.symbol) )/(SElecT LTP from historical_data B where date = '2023-04-02' and B.symbol = A.symbol))*100 as percent_ch from performance_metrics NATURAL JOIN transaction_history NATURAL JOIN company_profile A;

-- Q18

-- SElecT transaction_id, company_name, risk_level*sqrt((datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=1))/365)) as volatility from performance_metrics NATURAL JOIN transaction_history NATURAL JOIN company_profile;


-- Q19

-- SElecT transaction_id, company_name, annualized_return,risk_level from company_profile NATURAL JOIN transaction_history NATURAL JOIN performance_metrics order by -annualized_return, risk_level LIMIT 5;


-- Q20

-- SElecT transaction_id, sector, sum(quantity) as tot_shares from company_profile NATURAL JOIN performance_metrics NATURAL JOIN transaction_history group by sector ;


