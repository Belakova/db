6. ##Drop statements
drop table CustomerAccount_table;
drop table Employee_table;
drop table Customer_table;
drop table Account_table;
drop table Branch_table;


2.
Create type Name as object(
tittle VARCHAR2(8),
fname VARCHAR2(20),
sname VARCHAR2(20)
);

create type Address as object(
street VARCHAR2(25),
city VARCHAR2(20),
postcode VARCHAR2(10)
);

create type Phone as object(
mobile1 INTEGER,
mobile2 INTEGER,
home INTEGER
);


CREATE type Branch as object(
bID VARCHAR2(20),
bAddress Address,
bPhone INTEGER
);



create type Account as object(
accNum INTEGER,
accType VARCHAR2(15),
balance FLOAT,
bBranchID REF Branch, 		##foreign key ->> # REF Branch
inRate FLOAT,
limitOfFreeOD INTEGER, 	    ##can be null
openDate Date,
customer ref Customer ##new
);


create type Customer as object(
personID INTEGER,
personAddress Address,
personName Name,
personPhone Phone,
niNum VARCHAR2(9),
## nope ## accountNum Ref Account
) NOT FINAL; ## for the inheritance



create type Employee under Customer(
supervisorID REF Employee,		##another employees ID REF Employee
position VARCHAR2(20),
salary INTEGER,
bBranchID REF Branch,       ##foreign key ##REF Branch
joinDate Date
)not FINAL
method award()
#if position ='head'
#then supervisorID is null



##dont need it
create type CustomerAccount as object(
customerID Ref Customer,
accountNum Ref Account
);



3.
CREATE table Branch_table of Branch(
primary key (bID)
);



CREATE table Account_table of Account(
primary key  (accNum),
constraint acc_TYPE check (accType IN ('savings', 'current'))
);


CREATE table Employee_table of Employee(
primary key(personID));
##constraint supervisor_position check(position NOT IN('Head'))  head employee cant be supervisor



CREATE table Customer_table of Customer(
primary key (personID));


Create table CustomerAccount_table of CustomerAccount(
##  primary keys(customerID,accountNum) ##doesnt work
);



4. Data insertion
##
insert into Branch_table values(
901,Address('Market','Edinburgh','EH1 5AB'),01311235560);
insert into Branch_table values(
908,Address('Bridge','Glasgow','G18 1QQ'),01413214556);



##working
Insert into ACCOUNT_TABLE
Values(1001,'current',820.50,
(select REF(b)from BRANCH_TABLE b where b.BID=901),0.005,800,'01-MAY-11',
(select REF(cust) from Customer_table cust where cust.personID=1002));
insert into Account_table values(
1010,'savings',3122.20,(select REF(b)from BRANCH_TABLE b where b.BID=901),0.02,'','08-MAR-10',
(select REF(cust) from Customer_table cust where cust.personID=1002 and cust.personID=1003)
);
insert into Account_table values(
8002,'current',200,(select REF(b)from BRANCH_TABLE b where b.BID=908),0.005,100,'05-MAY-09',
(select REF(cust) from Customer_table cust where cust.personID=1098)
);




##working
insert into Employee_table values(
101,Address('Dart','Edinburgh','EH10 5TT'),Name('Mrs','Alison','Smith'),
Phone(07705623443,07907812345,''),'NI001',(select REF(s) from Employee_table s where s.personID=''),
'Head',50000,(select REF(b) from Branch_table b where b.bID=901),'01-FEB-06'
);
insert into Employee_table values(
105,Address('New','Edinburgh','EH2 4AB'),Name('Mr','John','William'),
Phone(07705623443,07907812345,01312125555),'NI010',(select REF(s) from Employee_table s where s.personID=101),
'Manager',40000 ,(select REF(b) from Branch_table b where b.bID=901),'04-MAR-07'
);
insert into Employee_table values(
108,Address('Old','Edinburgh','EH9 4BB'),Name('Mr','Mark','Slack'),
Phone('','',01312102211),'NI120',(select REF(s) from Employee_table s where s.personID=105),
'accountant',30000,(select REF(b) from Branch_table b where b.bID=901),'01-Feb-09'
);
insert into Employee_table values(
804,Address('Adam','Edinburgh','EH1 6EA'),Name('Mr','Jack','Smith'),
Phone(0781209890,'',01311112223),'NI810',(select REF(s) from Employee_table s where s.personID=801),'Manager',
35000,(select REF(b) from Branch_table b where b.bID=908),'05-Feb-08'
);



##working
insert into Customer_table values(
1002,Address('Adam','Edinburgh','EH1 6EA'),Name('Mr','Jack','Smith'),
Phone(0781209890,0771234567,01311112223),'NI810'
);
insert into Customer_table values(
1003,Address('Adam','Edinburgh','EH1 6EA'),Name('Ms','Anna','Smith'),
Phone( 0770111222,'',01311112223),'NI010'
);
insert into Customer_table values(
1098,Address('New','Edinburgh','EH2 8XN'),Name('Mr','Liam','Bain'),
Phone('','',01314425567 ),'NI034'
);



insert into CustomerAccount_table values(
(select REF(cust) from Customer_table cust where cust.personID=1002),
(select REF(acc) from Account_table acc where acc.accNum=1001));


insert into CustomerAccount_table values(
(select REF(cust) from Customer_table cust where cust.personID=1002),
(select REF(acc) from Account_table acc where acc.accNum=1010));


insert into CustomerAccount_table values(
(select REF(cust) from Customer_table cust where cust.personID=1003),
(select REF(acc) from Account_table acc where acc.accNum=1010));


insert into CustomerAccount_table values(
(select REF(cust) from Customer_table cust where cust.personID=1098),
(select REF(acc) from Account_table acc where acc.accNum=8002));


##
create or replace type body Account as
MEMBER function calcAccount()return
number is
acc number;
BEGIN
acc :=self.acc+acc;
return acc;
end calcAccount;
end;

4.
a.
#working
select emp.PERSONNAME.fname,emp.PERSONNAME.sname
from Employee_table emp
where emp.PERSONNAME.fname LIKE '%on%'
and emp.PERSONADDRESS.city ='Edinburgh';

b.
#working
select Count(*) as Total,acc.bBranchID.bID as Branch,acc.bBranchID.bAddress.street as Street,
acc.bBranchID.bAddress.city as City ,acc.bBranchID.bAddress.postcode as Poscode
from Account_table acc
where acc.ACCTYPE ='savings'
Group by acc.BBRANCHID;

c.
select MAX(acc.ACCOUNTNUM.balance),acc.CUSTOMERID.personName.fname as Name,
acc.CUSTOMERID.BBRANCHID.BID as BranchID
from CustomerAccount_table acc
where acc.ACCOUNTNUM.accType='savings'
Group by acc.ACCOUNTNUM.accNum;

##should work
select max(acc.balance) as highest,acc.BBRANCHID.bID as BranchID ,acc.limitOfFreeOD,
acc.customer.personName.fname as Name
from ACCOUNT_TABLE acc
where acc.accType='savings'
Group by acc.balance; ##

d.
#should work
select emp.bBranchID.bAddress.city as workIn, acc.bBranchID.Address.city as customerIn
from Employee_table emp, Account_table acc
where emp.Employee.supervisorID='Manager' and emp.niNum=acc.customer.niNum;


e.
select max(cust.limitOfFreeOD)
from Account_table acc;


f.


g.
#should work
select Count(emp.personID)
from Employee_table emp
where emp.supervisorID.personName.sname='William'
Group by emp.supervisorID.personID;


create or replace type body Account as
MEMBER function calcAccount()return
number is
acc number;
BEGIN
acc :=self.acc+acc;
return acc;
end calcAccount;
end;

h.
create method award()return for Employee
now DATE();
BEGIN
DATEDIFF(now,joinDate)
if
DATEDIFF(now,joinDate) >12
echo "gold medal"
acc :=self.acc+acc;
return acc;
end award;
end;
