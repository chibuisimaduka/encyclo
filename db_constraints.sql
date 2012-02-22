Alter TABLE association_definitions MODIFY entity_id int(11) NOT NULL;
Alter Table association_definitions ADD FOREIGN KEY (entity_id) REFERENCES entities(id);
-- Alter TABLE Persons ADD UNIQUE (column_blah)
-- Alter Table Orders ADD FOREIGN KEY (P_Id) REFERENCES Persons(P_Id)
