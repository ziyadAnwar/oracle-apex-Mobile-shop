
  CREATE TABLE "S_SELL_ORDER_ITEMS" 
   (	"SELL_ORDER_ITEM_ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"SELL_ORDER_ID" NUMBER, 
	"PRODUCT_ID" NUMBER, 
	"PRODUCT_PRICE" NUMBER, 
	"PRODUCT_QUANTITY" NUMBER, 
	"PRODUCT_TOTAL" NUMBER, 
	 CONSTRAINT "S_SELL_ORDER_ITEMS_PK" PRIMARY KEY ("SELL_ORDER_ITEM_ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "S_SELL_ORDER_ITEMS_CON" UNIQUE ("SELL_ORDER_ID", "PRODUCT_ID")
  USING INDEX  ENABLE
   ) ;

  ALTER TABLE "S_SELL_ORDER_ITEMS" ADD CONSTRAINT "S_SELL_ORDER_ITEMS_FK" FOREIGN KEY ("SELL_ORDER_ID")
	  REFERENCES "S_SELL_ORDER" ("SELL_ORDER_ID") ON DELETE SET NULL ENABLE;
  ALTER TABLE "S_SELL_ORDER_ITEMS" ADD CONSTRAINT "S_SELL_ORDER_ITEMS_FK2" FOREIGN KEY ("PRODUCT_ID")
	  REFERENCES "S_PRODUCT" ("PRODUCT_ID") ON DELETE SET NULL ENABLE;

  CREATE OR REPLACE EDITIONABLE TRIGGER "A_S_SELL_ORDER_ITEMS_T_1" 
BEFORE
INSERT OR UPDATE OR DELETE ON "S_SELL_ORDER_ITEMS"
FOR EACH ROW
DECLARE
    -- PRAGMA autonomous_transaction; -- Consider removing this if not necessary
BEGIN
    -- INSERTING block
    IF INSERTING THEN
        UPDATE S_PRODUCT
        SET S_PRODUCT.QUANTITY = S_PRODUCT.QUANTITY - :new.PRODUCT_QUANTITY
        WHERE S_PRODUCT.PRODUCT_ID = :new.PRODUCT_ID; -- Fixed table reference and added missing semicolon
    END IF;
    
    -- UPDATING block
    IF UPDATING THEN
        UPDATE S_PRODUCT
        SET S_PRODUCT.QUANTITY = (S_PRODUCT.QUANTITY + :old.PRODUCT_QUANTITY) - :new.PRODUCT_QUANTITY
        WHERE S_PRODUCT.PRODUCT_ID = :new.PRODUCT_ID;
    END IF;
    
    -- DELETING block
    IF DELETING THEN
        UPDATE S_PRODUCT
        SET S_PRODUCT.QUANTITY = S_PRODUCT.QUANTITY + :old.PRODUCT_QUANTITY
        WHERE S_PRODUCT.PRODUCT_ID = :old.PRODUCT_ID;
    END IF;
    
    -- No need to commit inside the trigger; this will be handled by the main transaction
    -- commit; -- Remove this, as commits are managed externally
END;
/
ALTER TRIGGER "A_S_SELL_ORDER_ITEMS_T_1" ENABLE;
  CREATE OR REPLACE EDITIONABLE TRIGGER "S_SELL_ORDER_ITEMS_T" 
before
insert on "S_SELL_ORDER_ITEMS"
for each row
begin
    IF :NEW."SELL_ORDER_ITEM_ID" IS NULL THEN
        SELECT "S_SELL_ORDER_ITEMS_SEQ".nextval into :NEW."SELL_ORDER_ITEM_ID" FROM SYS.DUAL;
    END IF;
end;
/
ALTER TRIGGER "S_SELL_ORDER_ITEMS_T" ENABLE;