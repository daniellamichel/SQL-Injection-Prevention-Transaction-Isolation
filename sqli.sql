
CREATE TABLE patient (
    pid integer NOT NULL,
    fname character varying(30),
    lname character varying(20),
    age integer
);

insert into patient values (1,'Lilly','Yu',52);
insert into patient values (2,'Olivia','Fletcher',100);
insert into patient values (3,'Anthony','Farrell',29);
insert into patient values (4,'Christopher','Potts',21);
insert into patient values (5,'John','Kidd',82);
insert into patient values (6,'Elizabeth','Dennis',100);
insert into patient values (7,'Ned','Bridges',7);
insert into patient values (8,'Benjamin','Crawford',87);
insert into patient values (9,'Jacob','Palmer',4);
insert into patient values (10,'Sophie','Bowen',51);
insert into patient values (11,'Emily','Lawson',91);
insert into patient values (12,'Ethan','Dodson',32);
insert into patient values (13,'Jacob','Bush',56);
insert into patient values (14,'Michael','Odom',71);
insert into patient values (15,'Jorge','Gentry',26);
insert into patient values (16,'Sophia','Calhoun',30);
insert into patient values (17,'Ava','Koch',99);
insert into patient values (18,'Andrew','Yang',55);
insert into patient values (19,'Heather','Armstrong',13);
insert into patient values (20,'Madison','Cortez',25);


CREATE TABLE claims (
	claim_id int primary key,
	claim_date DATE,
	doc VARCHAR(25),
	patient varchar(25)
);


 insert into claims (claim_id, claim_date, doc, patient) values (1, '2023-06-26', 'Snaddin', 'Carnaman');
 
 insert into claims (claim_id, claim_date, doc, patient) values (2, '2023-09-01', 'Jouhan', 'Bessom');
 
 insert into claims (claim_id, claim_date, doc, patient) values (3, '2022-12-08', 'Node', 'Heitz');
 
 insert into claims (claim_id, claim_date, doc, patient) values (4, '2022-11-11', 'McOwan', 'Guy');
 
 insert into claims (claim_id, claim_date, doc, patient) values (5, '2023-05-08', 'Stuehmeyer', 'Nattrass');
 
 insert into claims (claim_id, claim_date, doc, patient) values (6, '2023-02-02', 'Winterborne', 'Gaenor');
 
 insert into claims (claim_id, claim_date, doc, patient) values (7, '2023-04-19', 'Caldicott', 'Scrivner');
 
 insert into claims (claim_id, claim_date, doc, patient) values (8, '2023-01-16', 'Speenden', 'Coulbeck');
 
 insert into claims (claim_id, claim_date, doc, patient) values (9, '2023-04-28', 'Rowaszkiewicz', 'Laverack');
 
 insert into claims (claim_id, claim_date, doc, patient) values (10, '2023-05-01', 'Pierpoint', 'Karolyi');
 
 insert into claims (claim_id, claim_date, doc, patient) values (11, '2023-02-01', 'McComiskie', 'Le Marquand');
 
 insert into claims (claim_id, claim_date, doc, patient) values (12, '2023-05-13', 'Leftly', 'Farington');
 
 insert into claims (claim_id, claim_date, doc, patient) values (13, '2023-08-17', 'Algy', 'Gouldstone');
 
 insert into claims (claim_id, claim_date, doc, patient) values (14, '2023-10-15', 'Seivwright', 'Niesegen');
 
 insert into claims (claim_id, claim_date, doc, patient) values (15, '2023-08-19', 'Girvin', 'Cordero');
 
 insert into claims (claim_id, claim_date, doc, patient) values (16, '2022-12-22', 'Catteroll', 'Vlies');
 
 insert into claims (claim_id, claim_date, doc, patient) values (17, '2023-08-28', 'Macari', 'Schwartz');
 
 insert into claims (claim_id, claim_date, doc, patient) values (18, '2022-12-02', 'Braganza', 'Parkin');
 
 insert into claims (claim_id, claim_date, doc, patient) values (19, '2022-12-07', 'Randerson', 'Stienton');
 
 insert into claims (claim_id, claim_date, doc, patient) values (20, '2022-11-04', 'Trythall', 'Somerton');
 
