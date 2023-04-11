        # except:
        #     query2 = '''select max(transaction_id) from transaction_history'''
        #     cur = mysql.connection.cursor()
        #     cur.execute(query2)
        #     number = cur.fetchall()[0]
        #     query = '''delete from transaction_history where transaction_id=%s'''
        #     values = [number[0]]
        #     cur.execute(query,values)
        #     mysql.connection.commit()
        #     print(number[0])
        #     return render_template('alert3.html')