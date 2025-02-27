# Importing packages
import streamlit as st
import mysql.connector

from create import *
from database import *
from delete import *
from read import *
from update import *





def main():
    st.set_page_config(
    page_title = "My Cloth Store",
    page_icon = "👕",
    layout = "wide",
    initial_sidebar_state = "expanded",
    )
    
    #st.snow()
    st.sidebar.image("Fashion.png")
    st.title("Cloth Store Management System ")
    # Main Sections with improved UI layout
    st.write("🛍️ **Manage Your Store Efficiently**")
    st.divider()  # Adds a clean separation line
    #st.write("------------------------------------------------------")
    menu = ["ADD", "VIEW", "EDIT", "REMOVE"]
    st.sidebar.header("🔹 MENU")
    
    ch = st.sidebar.radio("📌 Select Category", ["CUSTOMER", "EMPLOYEE", "ITEMS-STOCK", "SUPPLIER"])
    option = st.sidebar.radio("⚡ Action", menu)
    ch2 = st.sidebar.selectbox("RUN ANY QUERY",["Click here/Scroll Down \u2193"])
    if ch == "CUSTOMER":
        cu_create_table()
        if option == "ADD":
            st.subheader("📝 Add New Customer")
            cu_create()

        elif option == "VIEW":
            st.subheader("👀 View Customers")
            cu_read()

        elif option == "EDIT":
            st.subheader("✏️ Edit Customer Details")
            cu_update()

        elif option == "REMOVE":
            st.subheader("❌ Remove Customer")
            cu_delete()

        else:
            st.subheader("About tasks")
            
#############################################################################################################

    if ch == "EMPLOYEE":
        em_create_table()
        if option == "ADD":
            st.subheader("📝 Add Employee")
            em_create()

        elif option == "VIEW":
            st.subheader("👀 View Employees")
            em_read()

        elif option == "EDIT":
            st.subheader("✏️ Edit Employee")
            em_update()

        elif option == "REMOVE":
            st.subheader("❌ Remove Employee")
            em_delete()

        else:
            st.subheader("About tasks")
            
#############################################################################################################

    if ch == "ITEMS-STOCK":
        it_create_table()
        if option == "ADD":
            st.subheader("📦 Add Items to Stock")
            it_create()

        elif option == "VIEW":
            st.subheader("🔍 View Inventory")
            it_read()

        elif option == "EDIT":
            st.subheader("✏️ Update Stock Items")
            it_update()

        elif option == "REMOVE":
            st.subheader("🗑️ Delete Items")
            it_delete()

        else:
            st.subheader("About tasks")
            
#############################################################################################################

    if ch == "SUPPLIER":
        su_create_table()
        if option == "ADD":
            st.subheader("📜 Add Supplier Details")
            su_create()

        elif option == "VIEW":
            st.subheader("🔍 View Suppliers")
            su_read()

        elif option == "EDIT":
            st.subheader("✏️ Edit Supplier Information")
            su_update()

        elif option == "REMOVE":
            st.subheader("🗑️ Remove Supplier")
            su_delete()

        else:
            st.subheader("About tasks")
       
#############################################################################################################
    def any_query_data(query):
        conn = mysql.connector.connect(**st.secrets["mysql"])
        cur = conn.cursor(buffered = True)
        cur.execute(query)
        result = cur.fetchall()
        conn.commit()
        conn.close()
        return result
    def any_query():
        st.subheader("RUN ANY QUERY")
        query = st.text_area("🔹 Enter your query here",value = "SELECT * FROM store")
        if st.button("Run Query"):
            result = any_query_data(query)
            df = pd.DataFrame(result)
            st.dataframe(df)
    st.write("------------------------------------------------------")
    if ch2 == "Click here/Scroll Down \u2193":
        any_query()


if __name__ == '__main__':
    main()
