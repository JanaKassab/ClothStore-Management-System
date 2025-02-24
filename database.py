# pip install mysql-connector-python
import mysql.connector
import streamlit as st
import pandas as pd

try:
    mydb = mysql.connector.connect(**st.secrets["mysql"])
    c = mydb.cursor(buffered = True)
except Exception as e:
    st.write("Error is :{}....Trying to Reconnect".format(e))
    mydb = mysql.connector.connect(**st.secrets["mysql"])
    c = mydb.cursor(buffered = True)    

#############################################################################################################

def cu_create_table():
    c.execute('CREATE TABLE IF NOT EXISTS customers(C_ID INT(11), C_First_Name VARCHAR(50),C_Last_Name VARCHAR(50),Qualification VARCHAR(20),C_ADDRESS VARCHAR(50),Locality VARCHAR(20),CITY VARCHAR(20),Email VARCHAR(50),C_Phone_NO VARCHAR(10),DOP date,E_ID INT(11))')
    c.execute('CREATE TABLE IF NOT EXISTS orders(C_ID INT(11), ITEM_ID INT(11), Price FLOAT, Quantity INT(11),O_Date date,O_Amount FLOAT)')

def cu_add_data(c_id,cf_name,cl_name,c_qual,c_address,c_locate,c_city,c_email,c_phone,c_dop,c_emp):
    c.execute('INSERT INTO customers(C_ID, C_First_Name,C_Last_Name,Qualification,C_ADDRESS,Locality,CITY,Email,C_Phone_NO,DOP,E_ID) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',(c_id,cf_name,cl_name,c_qual,c_address,c_locate,c_city,c_email,c_phone,c_dop,c_emp))    
    mydb.commit()

def cu_orders_add_data(c_id, c_item_id, c_price, c_qty, c_dop, c_total):
    c.execute('INSERT INTO orders(C_ID, Item_ID, Price, Quantity,O_Date,O_Amount) VALUES (%s,%s,%s,%s,%s,%s)',(c_id,c_item_id,c_price,c_qty,c_dop,c_total))
    mydb.commit()



def cu_view_all_data():
    c.execute('SELECT * FROM customers AS C JOIN orders AS O ON C.C_ID = O.C_ID GROUP BY O.C_ID, O.Item_ID ORDER BY O.C_ID;')
    data = c.fetchall()
    return data

def cu_view_cust_data():
    c.execute('SELECT C_ID,E_ID,C_First_Name,C_Last_Name,Qualification,C_Address,Locality,City,Email,C_Phone_NO FROM customers')
    data = c.fetchall()
    return data

def cu_view_cust_feature():
    c.execute('SELECT `C_ID`,`C_First_Name`,`C_Last_Name`, CustomerLevel(`C_ID`) FROM `customers`')
    data = c.fetchall()
    return data

def cu_view_only():
    c.execute('SELECT C_ID,C_First_Name,C_Last_Name FROM customers')
    data = c.fetchall()
    return data


def cu_get(c_id):
    c.execute('SELECT * FROM customers WHERE C_ID ="{}"'.format(c_id))
    data = c.fetchall()
    return data


def cu_edit(new_c_id,new_e_id,new_cf,new_cl,new_c_qual, new_c_address, new_c_locate, new_c_city, new_c_email,new_c_phone, c_id,e_id,c_fn, c_ln, c_qual, c_address, c_locate, c_city, c_email,c_phone):
    c.execute("UPDATE customers SET C_ID = %s ,E_ID = %s, C_First_Name = %s, C_Last_Name = %s, Qualification = %s, C_Address = %s, Locality = %s, City = %s, Email = %s, C_Phone_NO = %s  WHERE C_ID = %s and E_ID = %s and C_First_Name = %s and C_Last_Name = %s and Qualification = %s and C_Address = %s and Locality = %s and City = %s and Email = %s and C_Phone_NO = %s",(new_c_id,new_e_id,new_cf,new_cl,new_c_qual, new_c_address, new_c_locate, new_c_city, new_c_email,new_c_phone,c_id,e_id,c_fn,c_ln,c_qual, c_address, c_locate, c_city, c_email,c_phone))
    mydb.commit()
    try:
        data = c.fetchmany()
        return data
    except TypeError as e:
        #st.success("Successfully updated:: {} to :: {} and other details".format(c_fn, new_cf))
        pass
        


def cu_delete_data(c_id):
    c.execute('DELETE FROM customers WHERE C_ID = "{}"'.format(c_id))
    mydb.commit()

def cu_read_delete():
    c.execute("SELECT * FROM customer_backuplog")
    data = c.fetchall()
    return data
###################################################################################

def cu_bill(b_id, b_bank, c_dop,b_tid, b_amount,c_id):
    c.execute('CREATE TABLE IF NOT EXISTS bill(B_ID INT(11), BANK VARCHAR(50),DATE_OF_BILL date,Transaction_ID varchar(20), Amount float,C_ID INT(11))')
    c.execute('DELETE FROM bill WHERE C_ID = "{}"'.format(c_id))
    c.execute('INSERT INTO bill(B_ID, BANK,DATE_OF_BILL,Transaction_ID, Amount,C_ID) VALUES (%s,%s,%s,%s,%s,%s)',(b_id, b_bank, c_dop,b_tid, b_amount,c_id))
    mydb.commit()

def bill_view_all_data(c_id):
    c.execute('SELECT B_ID,Bank,Date_Of_Bill,Transaction_ID,Amount FROM bill WHERE C_ID = "{}"'.format(c_id))
    data = c.fetchall()
    return data

#####
def bill_view_all_data2(c_id):
    c.execute('SELECT Item_ID,I_Name,Brand,Size,Quantity,Total FROM Bills WHERE C_ID = "{}"'.format(c_id))
    data = c.fetchall()
    return data

def bill_view_all_data3(c_id):
    c.execute('SELECT Discount(C_ID) FROM bill WHERE C_ID = "{}"'.format(c_id))
    data = c.fetchall()
    price_data = []
    for i in data:
        for j in i:
            price_data.append(float(j))
    r1 = price_data[0]
    c.execute('SELECT Amount FROM bill WHERE C_ID = "{}"'.format(c_id))
    data2 = c.fetchall()
    price_data = []
    for i in data2:
        for j in i:
            price_data.append(float(j))
    r2 = price_data[0]
    res = r2 - r1
    return data,res

def view_bill(c_id):
    result = bill_view_all_data(c_id)
    result2 = bill_view_all_data2(c_id)
    result3,res4 = bill_view_all_data3(c_id)
    # st.write(result)
    st.markdown(' `BILL SUMMARY:` ')
    df = pd.DataFrame(result2, columns = ['Item_ID','Item_Name','Brand','Size','Quantity','Total'])
    st.dataframe(df)
    st.markdown(' `TOTAL AMOUNT:` ')
    df = pd.DataFrame(result, columns = ['Bill_ID','Bank','Date_Of_Bill','Transaction_ID','Amount'])
    st.dataframe(df)
    st.markdown(' `DISCOUNT:` ')
    df = pd.DataFrame(result3, columns = ['Discount'])
    st.dataframe(df)
    st.markdown('TOTAL AMOUNT AFTER DISCOUNT: `$ {}`'.format(res4))

#############################################################################################################

def em_create_table():
    c.execute('CREATE TABLE IF NOT EXISTS employee(E_ID INT(11), E_First_Name VARCHAR(30),E_Last_Name VARCHAR(30),MGR_ID INT(11), E_GENDER VARCHAR(1),SALARY float, E_DOB date, E_ADDRESS VARCHAR(50),E_Phone_NO VARCHAR(10))')

def em_add_data(e_id,e_fn,e_ln,emgr_id,e_gender,e_salary,e_dob,e_address,e_phone):
    c.execute('INSERT INTO employee(E_ID,e_First_Name,E_Last_Name,MGR_ID,E_GENDER,SALARY,E_DOB,E_ADDRESS,E_Phone_NO) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)',(e_id,e_fn,e_ln,emgr_id,e_gender,e_salary,e_dob,e_address,e_phone))
    mydb.commit()


def em_view_all_data():
    c.execute('SELECT * FROM employee')
    data = c.fetchall()
    return data


def em_view_only():
    c.execute('SELECT E_First_name FROM employee')
    data = c.fetchall()
    return data


def em_get(e_fn):
    c.execute('SELECT * FROM employee WHERE E_First_Name="{}"'.format(e_fn))
    data = c.fetchall()
    return data


def em_edit(new_e_id,new_e_fn,new_e_ln,new_emgr_id,new_e_gender,new_e_salary,new_e_dob,new_e_address,new_e_phone,e_id,e_fn,e_ln,emgr_id,e_gender,e_salary,e_dob,e_address,e_phone):
    c.execute("UPDATE employee SET E_ID = %s, E_First_Name = %s,E_Last_Name = %s,MGR_ID = %s,E_GENDER = %s,SALARY = %s,E_DOB = %s,E_ADDRESS = %s,E_Phone_NO = %s  WHERE E_ID = %s AND E_First_Name = %s AND E_Last_Name = %s AND MGR_ID = %s AND E_GENDER = %s AND SALARY = %s AND E_DOB = %s AND E_ADDRESS = %s AND E_Phone_NO = %s", (new_e_id,new_e_fn,new_e_ln,new_emgr_id,new_e_gender,new_e_salary,new_e_dob,new_e_address,new_e_phone,e_id,e_fn,e_ln,emgr_id,e_gender,e_salary,e_dob,e_address,e_phone))
    mydb.commit()
    try:
        data = c.fetchmany()
        return data
    except TypeError as e:
        pass

def em_delete_data(e_fn):
    c.execute('DELETE FROM employee WHERE E_First_Name = "{}"'.format(e_fn))
    mydb.commit()


#############################################################################################################

def it_create_table():
    c.execute('CREATE TABLE IF NOT EXISTS items(ITEM_ID INT(11),I_Name VARCHAR(30),Price float)')
    c.execute('CREATE TABLE IF NOT EXISTS item_category(CATEGORYITEM_ID INT(11),Item_Name VARCHAR(30),I_Gender VARCHAR(1),BRAND VARCHAR(30),COLOUR VARCHAR(20),SIZE VARCHAR(10))')
    c.execute('CREATE TABLE IF NOT EXISTS contains(STORE_ID INT(11),ITEM_ID INT(11),QUANTITY INT(11))')

def it_add_data(i_id,i_name,i_price,i_gender,i_brand,i_colour,i_size,i_quantity,st_id):
    c.execute('INSERT INTO items(Item_ID,I_Name,Price) VALUES (%s,%s,%s)',(i_id,i_name,i_price))
    c.execute('INSERT INTO item_category(CATEGORYITEM_ID,Item_Name,I_Gender,BRAND,COLOUR,SIZE) VALUES (%s,%s,%s,%s,%s,%s)',(i_id,i_name,i_gender,i_brand,i_colour,i_size))
    c.execute('INSERT INTO contains(STORE_ID,ITEM_ID,QUANTITY) VALUES (%s,%s,%s)',(st_id,i_id,i_quantity))
    mydb.commit()


def it_view_all_data():
    c.execute('SELECT I.ITEM_ID, I.I_Name,IC.I_Gender,IC.Brand,IC.Colour,IC.Size, C.Quantity,C.Store_ID,S.ST_Name FROM item_category AS IC JOIN items AS I ON IC.CATEGORYITEM_ID=I.ITEM_ID JOIN contains AS C ON I.ITEM_ID=C.ITEM_ID JOIN store AS S ON C.STORE_ID=S.STORE_ID')
    data = c.fetchall()
    return data


def it_view_only():
    c.execute('SELECT I.ITEM_ID, I.I_Name,I.Price,IC.I_Gender,IC.Brand,IC.Colour,IC.Size, C.Quantity,C.Store_ID FROM item_category AS IC JOIN items AS I ON IC.CATEGORYITEM_ID=I.ITEM_ID JOIN contains AS C ON I.ITEM_ID=C.ITEM_ID')
    data = c.fetchall()
    return data


def it_get(i_id):
    c.execute('SELECT I.ITEM_ID, I.I_Name,I.Price,IC.I_Gender,IC.Brand,IC.Colour,IC.Size, C.Quantity,C.Store_ID FROM item_category AS IC JOIN items AS I ON IC.CATEGORYITEM_ID=I.ITEM_ID JOIN contains AS C ON I.ITEM_ID=C.ITEM_ID WHERE I.Item_ID="{}"'.format(i_id))
    data = c.fetchall()
    return data


def it_edit(new_i_id,new_i_name,new_i_price,new_i_gender,new_i_brand,new_i_colour,new_i_size,new_i_quantity,new_st_id,i_id,i_name,i_price,i_gender,i_brand,i_colour,i_size,i_quantity,st_id):
    c.execute("UPDATE items SET Item_ID = %s, I_Name = %s, Price = %s  WHERE Item_ID = %s and Item_Name = %s and Price = %s", (new_i_id,new_i_name,new_i_price,i_id,i_name,i_price))
    c.execute("UPDATE item_category SET CATEGORYITEM_ID = %s, Item_Name = %s,I_GENDER = %s,BRAND = %s,COLOUR = %s,SIZE = %s  WHERE CATEGORYITEM_ID = %s and Item_Name = %s and I_Gender = %s and BRAND = %s and COLOUR = %s and SIZE = %s", (new_i_id,new_i_name,new_i_gender,new_i_brand,new_i_colour,new_i_size,i_id,i_name,i_gender,i_brand,i_colour,i_size))
    c.execute("UPDATE contains SET STORE_ID = %s, ITEM_ID = %s, QUANTITY = %s  WHERE STORE_ID=%s and ITEM_ID=%s and QUANTITY=%s", (new_st_id,new_i_id,new_i_quantity,st_id,i_id,i_quantity))
    mydb.commit()
    try:
        data = c.fetchmany()
        return data
    except TypeError as e:
        pass


def it_delete_data(i_id):
    c.execute('DELETE FROM items WHERE Item_ID = "{}"'.format(i_id))
    mydb.commit()

#############################################################################################################

def su_create_table():
    c.execute('CREATE TABLE IF NOT EXISTS suppliers(SUPP_ID int(11), SU_NAME varchar(50), SU_ADDRESS varchar(50))')
    c.execute('CREATE TABLE IF NOT EXISTS ships(COST_OF_SHIPPING float,MODE_OF_TRAVEL varchar(50),SUPP_ID int(11), SHIP_ID int(11))')
    c.execute('CREATE TABLE IF NOT EXISTS shipment(Ship_ID int(11),Date_Of_Shipment date,Store_ID INT(11))')

def su_add_data(su_id,su_name,su_address,sh_id,sh_cost,sh_mode,sh_date,su_st_id):
    c.execute('INSERT INTO suppliers(SUPP_ID,SU_NAME,SU_ADDRESS) VALUES (%s,%s,%s)',(su_id,su_name,su_address))
    c.execute('INSERT INTO ships(COST_OF_SHIPPING,MODE_OF_TRAVEL,SUPP_ID,SHIP_ID) VALUES (%s,%s,%s,%s)',(sh_cost,sh_mode,su_id,sh_id))
    c.execute('INSERT INTO shipment(Ship_PID,Date_Of_Shipment,Store_ID) VALUES (%s,%s,%s)',(sh_id,sh_date,su_st_id))
    mydb.commit()

def su_view_all_data():
    c.execute('SELECT SU.Supp_ID,SU.SU_Name,SU.SU_Address,SH.Ship_ID,SH.Cost_of_shipping,SH.mode_of_Travel,S.Date_Of_Shipment,S.Store_ID FROM suppliers AS SU JOIN ships AS SH ON SU.SUPP_ID=SH.SUPP_ID JOIN shipment AS S ON SH.SHIP_ID=S.SHIP_PID')
    data = c.fetchall()
    return data

def su_view_only():
    c.execute('SELECT SU_Name FROM suppliers')
    data = c.fetchall()
    return data


def su_get(su_name):
    c.execute('SELECT SU.Supp_ID,SU.SU_Name,SU.SU_Address,SH.Ship_ID,SH.Cost_of_shipping,SH.mode_of_Travel,S.Date_Of_Shipment,S.Store_ID FROM suppliers AS SU JOIN ships AS SH ON SU.SUPP_ID=SH.SUPP_ID JOIN shipment AS S ON SH.SHIP_ID=S.SHIP_PID WHERE SU.SU_Name="{}"'.format(su_name))
    data = c.fetchall()
    return data


def su_edit(new_su_id,new_su_name,new_su_address,new_sh_id,new_sh_cost,new_sh_mode,new_sh_date,new_su_st_id,su_id,su_name,su_address,sh_id,sh_cost,sh_mode,sh_date,su_st_id):
    c.execute("UPDATE suppliers SET SUPP_ID = %s, SU_NAME = %s, SU_ADDRESS = %s  WHERE SUPP_ID = %s AND SU_NAME = %s AND SU_ADDRESS = %s", (new_su_id,new_su_name,new_su_address,su_id,su_name,su_address))
    c.execute("UPDATE ships SET COST_OF_SHIPPING = %s,MODE_OF_TRAVEL = %s,SUPP_ID = %s, SHIP_ID = %s  WHERE COST_OF_SHIPPING = %s and MODE_OF_TRAVEL = %s and SUPP_ID = %s and SHIP_ID = %s", (new_sh_cost,new_sh_mode,new_su_id,new_sh_id,sh_cost,sh_mode,su_id,sh_id))
    c.execute("UPDATE shipment SET Ship_PID = %s,Date_Of_Shipment = %s,Store_ID = %s  WHERE Ship_PID = %s and Date_Of_Shipment = %s and Store_ID = %s", (new_sh_id,new_sh_date,new_su_st_id,sh_id,sh_date,su_st_id))
    mydb.commit()
    try:
        data = c.fetchmany()
        return data
    except TypeError as e:
        pass


def su_delete_data(su_name):
    c.execute('DELETE FROM suppliers WHERE SU_Name = "{}"'.format(su_name))
    mydb.commit()

#############################################################################################################
