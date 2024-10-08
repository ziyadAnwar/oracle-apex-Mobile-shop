
  CREATE TABLE "S_SELL_ORDER" 
   (	"SELL_ORDER_ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"SELL_ORDER_DATE" DATE, 
	"SELL_ORDER_TOTAL" NUMBER, 
	"SELL_ORDER_CLIENT_ID" NUMBER, 
	 CONSTRAINT "S_SELL_ORDER_PK" PRIMARY KEY ("SELL_ORDER_ID")
  USING INDEX  ENABLE
   ) ;

  ALTER TABLE "S_SELL_ORDER" ADD CONSTRAINT "S_SELL_ORDER_CON" FOREIGN KEY ("SELL_ORDER_CLIENT_ID")
	  REFERENCES "S_CLIENT" ("CLIENT_ID") ON DELETE SET NULL ENABLE;

  CREATE OR REPLACE EDITIONABLE TRIGGER "S_SELL_ORDER_T" 
before
insert  on "S_SELL_ORDER"
for each row
begin
    IF :NEW."SELL_ORDER_ID" IS NULL THEN
        SELECT "S_SELL_ORDER_SEQ".nextval into :NEW."SELL_ORDER_ID" FROM SYS.DUAL;
    END IF;
end;
/
ALTER TRIGGER "S_SELL_ORDER_T" ENABLE;
  CREATE OR REPLACE EDITIONABLE TRIGGER "S_SELL_ORDER_T_1" 
BEFORE INSERT OR UPDATE OR DELETE ON "S_SELL_ORDER"
FOR EACH ROW
DECLARE
BEGIN
  IF INSERTING THEN
    UPDATE S_CLIENT
    SET S_CLIENT.CLIENT_BALANCE = S_CLIENT.CLIENT_BALANCE + :new.SELL_ORDER_TOTAL
    WHERE S_CLIENT.CLIENT_ID = :new.SELL_ORDER_CLIENT_ID;
  END IF;

  IF UPDATING THEN
    UPDATE S_CLIENT
    SET S_CLIENT.CLIENT_BALANCE = (S_CLIENT.CLIENT_BALANCE + :new.SELL_ORDER_TOTAL) - :old.SELL_ORDER_TOTAL
    WHERE S_CLIENT.CLIENT_ID = :new.SELL_ORDER_CLIENT_ID;
  END IF;

  IF DELETING THEN
    UPDATE S_CLIENT
    SET S_CLIENT.CLIENT_BALANCE = S_CLIENT.CLIENT_BALANCE - :old.SELL_ORDER_TOTAL
    WHERE S_CLIENT.CLIENT_ID = :old.SELL_ORDER_CLIENT_ID;
  END IF;
END;
/
ALTER TRIGGER "S_SELL_ORDER_T_1" ENABLE;