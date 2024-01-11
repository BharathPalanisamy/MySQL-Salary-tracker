import logging
import os
import mysql.connector

# Function to create a new log file
def fncWriteToLog(file_name, file_path, comment, level=logging.INFO):
    try:
        if not os.path.exists(file_path):
            os.makedirs(file_path)

        logger = logging.getLogger('my_logger')
        logger.setLevel(level)

        log_file_name = file_name + '.log'
        log_file_path = os.path.join(file_path, log_file_name)

        handler = logging.FileHandler(log_file_path, 'a')
        formatter = logging.Formatter('%(asctime)s - %(message)s', '%Y/%m/%d %H:%M:%S')
        handler.setFormatter(formatter)

        logger.addHandler(handler)
        logger.info(comment)
        return logger, log_file_path

    except Exception as e:
        logging.exception(f"An error occurred while creating or updating the log file: {e}")
        return None, None

# Function to update an existing log file
def fncUpdateToLog(log_file_path, comment, level=logging.INFO):
    try:
        if not os.path.exists(log_file_path):
            raise FileNotFoundError("The specified log file does not exist. Please create a new file.")

        logger = logging.getLogger('my_logger')
        logger.setLevel(level)

        handler = logging.FileHandler(log_file_path, 'a')
        formatter = logging.Formatter('%(asctime)s - %(message)s', '%Y/%m/%d %H:%M:%S')
        handler.setFormatter(formatter)

        logger.addHandler(handler)
        logger.info(comment)
        return logger

    except Exception as e:
        logging.exception(f"An error occurred while updating the log file: {e}")
        return None

# Function to execute MySQL queries and log results
def fncWriteToFile(file_name, file_path, query, level=logging.INFO):
    try:
        mydb = mysql.connector.connect(
            host="localhost",
            user="root",
            password="Bharath12!",
            database="employees"
        )

        logger, log_file_path = fncWriteToLog(file_name, file_path, "The database has been successfully connected.", level)

        if mydb.is_connected():
            cursor = mydb.cursor()
            cursor.execute(query)
            result = cursor.fetchall()

            result_file_path = os.path.join(file_path, f"{file_name}_results.log")
            with open(result_file_path, 'w') as result_file:
                result_file.write("Results of the query:\n")
                result_file.write("\n".join(str(row) for row in result))

            comment_end = "The database connection has been successfully ended."
            fncUpdateToLog(log_file_path, comment_end)

            cursor.close()
            mydb.close()

    except mysql.connector.Error as e:
        logging.exception(f"An error occurred while executing the query: {e}")

if __name__ == "__main__":
    logging.basicConfig(filename='error.log', level=logging.ERROR)

    try:
        file_name = input("Please enter the name of the file: ")
        file_path = input("Where do you want to store the file: ")
        existing_or_new_file = input("Is this a new file or existing file? Type 'a' for new file or 'u' for existing file: ")
        comment = input("Please enter a comment that you want to see in the log file: ")

        if existing_or_new_file == 'a':
            _, log_file_path = fncWriteToLog(file_name, file_path, comment)
        elif existing_or_new_file == 'u':
            log_file_path = os.path.join(file_path, file_name + '.log')
            fncUpdateToLog(log_file_path, comment)
        else:
            print("Invalid input for file status. Please enter 'a' for new file or 'u' for existing file.")

        # Example of executing and logging a query
        query = '''
        WITH MaxSalaries AS (
    -- Select the year from from_date and calculate the maximum salary for each year.
    SELECT
        YEAR(s.from_date) AS year,
        MAX(s.salary) AS max_salary
    FROM salaries s
    GROUP BY YEAR(s.from_date)
)
-- Select employee information for those who received the maximum salary for each year.
SELECT 
    -- Select employee details, including employee number, first name, last name, and salary.
    -- Include the year from the salary period.
    ms.year,
    e.first_name,
    e.last_name,
    s.salary
FROM employees e
-- Join the employees table with the salaries table based on employee number.
INNER JOIN salaries s ON e.emp_no = s.emp_no
-- Join the result with the MaxSalaries CTE based on the year and maximum salary.
INNER JOIN MaxSalaries ms ON YEAR(s.from_date) = ms.year AND s.salary = ms.max_salary
order by ms.year
LIMIT 5;
 '''
        fncWriteToFile(file_name, file_path, query)

    except Exception as e:
        logging.exception(f"An unexpected error occurred: {e}")
