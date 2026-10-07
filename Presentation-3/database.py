import mysql.connector

def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="kalki@2898ad",
        database="fuel_station_management"
    )