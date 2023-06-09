from flask import Flask, render_template, request, session
from flask_mysqldb import MySQL
from datetime import timedelta
import hashlib
import yaml
from json import dumps
import time
import secrets


app = Flask(__name__)
mysql = MySQL(app)
db = yaml.load(open('db.yaml'), Loader=yaml.Loader)
secret_key = secrets.token_hex(16)
app.secret_key = secret_key
app.permanent_session_lifetime = timedelta(minutes=10) # Session lasts for 10 minutes

app.config['MYSQL_USER'] = db['mysql_user']
app.config['MYSQL_PASSWORD'] = db['mysql_password']
app.config['MYSQL_HOST'] = db['mysql_host']
app.config['MYSQL_DB'] = db['mysql_db']
# Default is tuples
# app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        session.permanent = True
        user_details = request.form
        try:
            # If not logged in case
            username = user_details['username']
            password = user_details['password']

            # Password hashing to 224 characters
            password_hashed = hashlib.sha224(password.encode()).hexdigest()
        except:
            try:
                if request.form['logout'] == '':
                # If logged in case (for signout form return)
                    session.pop('user')
                    return render_template('/index.html', session=session)
            except:
                username = user_details['new_username']
                email = user_details['new_email']
                password2 = user_details['password']
                password_hashed2 = hashlib.sha224(password2.encode()).hexdigest()
                cur = mysql.connection.cursor()
                cur.execute("insert into user_profile(username, email, user_password) VALUES(%s, %s, %s)",(username, email, password_hashed2))
                mysql.connection.commit()
                return render_template('/index.html', session=session)
        cur = mysql.connection.cursor()
        cur.execute('''select username, user_password from user_profile''')
        mysql.connection.commit()
        all_users = cur.fetchall()
        for user in all_users:
            # Check if the entered username and password is correct
            if user[0] == username and user[1] == password_hashed:
                session['user'] = username
                return portfolio()
        return render_template('alert2.html')
    else:
        return render_template('index.html', session=session)


@app.route('/portfolio.html')
def portfolio():

    # Check if we have logged in users
    if "user" not in session:
        return render_template('alert1.html')

    # Query for holdings
    cur = mysql.connection.cursor()
    user = [session['user']]
    query = '''SELECT transaction_id, symbol, company_name, LTP, sector, quantity, quantity*(LTP) from transaction_history NATURAL JOIN company_profile NATURAL JOIN company_price where username = %s;'''
    cur.execute(query, user)
    holdings = cur.fetchall()

    # Query for watchlist
    query_watchlist = '''select symbol, LTP, PC, round((LTP-PC), 2) AS CH, round(((LTP-PC)/PC)*100, 2) AS CH_percent from watchlist
natural join company_price
where username = %s
order by (symbol)
'''
    cur.execute(query_watchlist, user)
    watchlist = cur.fetchall()
    #Query for performance metrics
    query_performance_metrics = '''Select symbol,total_return,annualized_return,risk_level,risk_level*sqrt((datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=1))/365)) from performance_metrics NATURAL JOIN transaction_history
    where username = %s 
    order by transaction_id; '''

    cur.execute(query_performance_metrics, user)
    performance_metrics = cur.fetchall()


    # Query for stock suggestion
    query_suggestions = '''select symbol, EPS, ROE, book_value, rsi, adx, pe_ratio, macd from company_price
natural join fundamental_averaged
natural join technical_signals
natural join company_profile 
where 
EPS>25 and roe>13 and 
book_value > 100 and
rsi>50 and adx >23 and
pe_ratio < 35 and
macd = 'bull'
order by symbol;
'''
    cur.execute(query_suggestions)
    suggestions = cur.fetchall()

    # Query on EPS
    query_eps = '''select symbol, ltp, eps from fundamental_averaged
where eps > 30
order by eps;'''
    cur.execute(query_eps)
    eps = cur.fetchall()

    # Query on PE Ratio

    query_pe = '''select symbol, ltp, pe_ratio from fundamental_averaged
where pe_ratio <30;'''
    cur.execute(query_pe)
    pe = cur.fetchall()

    # Query on technical signals
    query_technical = '''select * from technical_signals
where ADX > 23 and rsi>50 and rsi<70 and MACD = 'bull';'''
    cur.execute(query_technical)
    technical = cur.fetchall()

    # Query for pie chart
    query_sectors = '''select C.sector, sum(A.quantity*B.LTP) as current_value 
from holdings_view A
inner join company_price B
on A.symbol = B.symbol
inner join company_profile C
on A.symbol = C.symbol
where username = %s
group by C.sector;
'''
    cur.execute(query_sectors, user)
    sectors_total = cur.fetchall()
    # Convert list to json type having percentage and label keys
    piechart_dict = toPercentage(sectors_total)
    piechart_dict[0]['type'] = 'pie'
    piechart_dict[0]['hole'] = 0.4

    #Query for Portfolio's Annualized return
    quere_ar = ''' SElecT( (SElecT sum(annualized_return*quantity) from performance_metrics NATURAL JOIN transaction_history) / (SElecT sum(quantity) from transaction_history)) as Annual_return_of_portfolio;
'''
    cur.execute(quere_ar)
    port_ar = cur.fetchall()
    return render_template('portfolio.html', holdings=holdings, user=user[0], suggestions=suggestions, eps=eps, pe=pe, technical=technical, watchlist=watchlist, piechart=piechart_dict, performance_metrics=performance_metrics, port_ar = port_ar
)


def toPercentage(sectors_total):
    json_format = {}
    total = 0

    for row in sectors_total:
        total += row[1]

    json_format['values'] = [round((row[1]/total)*100, 2)
                             for row in sectors_total]
    json_format['labels'] = [row[0] for row in sectors_total]
    return [json_format]
    
def list_to_json(listToConvert):
    json_format = {}
    temp_dict = {}
    val_per = []
    for value in listToConvert:
        temp_dict[value] = listToConvert.count(value)

    values = [val for val in temp_dict.values()]
    for i in range(len(values)):
        per = ((values[i]/sum(values))*100)
        val_per.append(round(per, 2))
    keys = [k for k in temp_dict.keys()]
    json_format['values'] = val_per
    json_format['labels'] = keys
    return [json_format]

@app.route('/filtered1.html')
def filtered1():
    # Check if we have logged in users

    if "user" not in session:
        return render_template('alert1.html')
    user = [session['user']]
    cur = mysql.connection.cursor()
    query = '''SElecT symbol, company_name, LTP, sector, quantity, risk_level from company_price NATURAL JOIN company_profile NATURAL JOIN transaction_history NATURAL JOIN performance_metrics order by risk_level LIMIT 5;'''
    cur.execute(query);
    data = cur.fetchall()
    return render_template('filtered1.html', user=user[0], data=data)

@app.route('/filtered2.html')
def filtered2():
    # Check if we have logged in users

    if "user" not in session:
        return render_template('alert1.html')
    user = [session['user']]
    cur = mysql.connection.cursor()
    query = '''SElecT symbol, company_name, LTP, sector, quantity, annualized_return from company_price NATURAL JOIN company_profile NATURAL JOIN transaction_history NATURAL JOIN performance_metrics order by -annualized_return, risk_level LIMIT 5;'''
    cur.execute(query);
    data = cur.fetchall()
    return render_template('filtered2.html', user=user[0], data=data)

@app.route('/filtered3.html')
def filtered3():
    # Check if we have logged in users

    if "user" not in session:
        return render_template('alert1.html')
    user = [session['user']]
    cur = mysql.connection.cursor()
    query = '''SElecT symbol, sector, avg(annualized_return), sum(quantity) from company_profile NATURAL JOIN performance_metrics NATURAL JOIN transaction_history group by sector;
'''
    cur.execute(query);
    data = cur.fetchall()
    return render_template('filtered3.html', user=user[0], data=data)

@app.route('/delete_transaction.html', methods=['GET', 'POST'])
def delete_transaction():
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        transaction_details = request.form
        transaction_id = transaction_details['transaction_id']
        cur = mysql.connection.cursor()
        print(transaction_id)
        query1 = '''delete from performance_metrics where transaction_id=%s'''
        query2 = '''delete from transaction_history where transaction_id=%s'''
        cur.execute("delete from performance_metrics where transaction_id=%s",[transaction_id])
        cur.execute("delete from transaction_history where transaction_id=%s",[transaction_id])
        mysql.connection.commit()
    return render_template('delete_transaction.html')

@app.route('/add_transaction.html', methods=['GET', 'POST'])
def add_transaction():

    # Query for all companies (for drop down menu)
    cur = mysql.connection.cursor()
    query_companies = '''select symbol from company_profile'''
    cur.execute(query_companies)
    companies = cur.fetchall()

    if request.method == 'POST':
        transaction_details = request.form
        symbol = transaction_details['symbol']
        date = transaction_details['transaction_date']
        transaction_type = transaction_details['transaction_type']
        quantity = float(transaction_details['quantity'])
        rate = float(transaction_details['rate'])
        if transaction_type == 'Sell':
            quantity = -quantity

        try:
            cur = mysql.connection.cursor()
            query1 = '''insert into transaction_history(username, symbol, transaction_date, quantity, rate) values
(%s, %s, %s, %s, %s)'''
            values = [session['user'], symbol, date, quantity, rate]
            cur.execute(query1, values)
            mysql.connection.commit()
            cur = mysql.connection.cursor()
            query2 = '''select max(transaction_id) from transaction_history'''
            cur.execute(query2)
            number = cur.fetchall()[0]
            query3 = '''insert into performance_metrics(transaction_id,total_return, annualized_return, risk_level) values
(%s,((((SElecT rate from transaction_history where transaction_id = %s) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=%s)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=%s)))*100,
if(((((SElecT rate from transaction_history where transaction_id = %s) -((SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=%s)))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=%s)))*100>0,(power(1+(((SElecT rate from transaction_history where transaction_id = %s) -(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=%s))))/(SElecT LTP from company_price where symbol = (SElecT symbol from transaction_history where transaction_id=%s))*100,365/(datediff('2023-04-10',(SElecT transaction_date from transaction_history where transaction_id=%s))))-1)*100,0),
(select stddev(LTP) from historical_data where symbol = (SElecT symbol from transaction_history where transaction_id=%s)));'''
            values = [number[0],number[0],number[0],number[0],number[0],number[0],number[0],number[0],number[0],number[0],number[0],number[0]]
            cur.execute(query3,values)
            mysql.connection.commit()
        except:
            query2 = '''select max(transaction_id) from transaction_history'''
            cur = mysql.connection.cursor()
            cur.execute(query2)
            number = cur.fetchall()[0]
            query = '''delete from transaction_history where transaction_id=%s'''
            values = [number[0]]
            cur.execute(query,values)
            mysql.connection.commit()
            print(number[0])
            return render_template('alert3.html')

    return render_template('add_transaction.html', companies=companies)

@app.route('/filter_by_date.html', methods=['GET', 'POST'])
def filter_by_date():

    # Query for all companies (for drop down menu)
    cur = mysql.connection.cursor()
    query_companies = '''select symbol from company_profile'''
    cur.execute(query_companies)
    companies = cur.fetchall()

    if request.method == 'POST':
        filter_by_date_details = request.form
        symbol = filter_by_date_details['symbol']
        min_date = filter_by_date_details['transaction_date_min']
        max_date = filter_by_date_details['transaction_date_max']
        cur = mysql.connection.cursor()
        query = '''SElecT date, symbol, LTP, PC FROM historical_data
        where symbol = %s AND date BETWEEN %s and %s order by date'''
        values = [symbol, min_date, max_date]
        cur.execute(query, values)
        rv = cur.fetchall()
        return render_template('filtered4.html', values=rv)
    return render_template('filter_by_date.html', companies=companies)

@app.route('/perch_by_date.html', methods=['GET', 'POST'])
def perrch_by_date():

    # Query for all companies (for drop down menu)
    cur = mysql.connection.cursor()
    query_companies = '''select symbol from company_profile'''
    cur.execute(query_companies)
    companies = cur.fetchall()

    if request.method == 'POST':
        perch_by_date_details = request.form
        symbol = perch_by_date_details['symbol']
        min_date = perch_by_date_details['transaction_date_min']
        max_date = perch_by_date_details['transaction_date_max']
        cur = mysql.connection.cursor()
        query = '''SElecT symbol, ((((SElecT LTP from historical_data where date = %s and symbol = %s) -(SElecT LTP from historical_data B where date = %s and symbol = %s) )/(SElecT LTP from historical_data B where date = %s and symbol = %s))*100)  FROM company_profile
        where symbol = %s'''
        values = [max_date, symbol, min_date, symbol, min_date, symbol, symbol]
        cur.execute(query, values)
        rv = cur.fetchall()
        return render_template('filtered5.html', values=rv)
    return render_template('perch_by_date.html', companies=companies)

@app.route('/calc_correl.html', methods=['GET', 'POST'])
def calc_correl():

    if request.method == 'POST':
        calc_correl_details = request.form
        ID1 = calc_correl_details['transaction_id1']
        ID2 = calc_correl_details['transaction_id2']
        cur = mysql.connection.cursor()
        query = '''SElecT((SElecT avg(A - (SElecT Avg(A) from (SElecT C.LTP as A, D.LTP as B from historical_data C, historical_data D where C.symbol = (SElecT symbol as symA from transaction_history where transaction_id = %s) AND D.symbol = (SElecT symbol as symB from transaction_history where transaction_id = %s AND C.date = D.date)) as new_tab))
* avg(B - (SElecT avg(B) from (SElecT C.LTP as A, D.LTP as B from historical_data C, historical_data D where C.symbol = (SElecT symbol as symA from transaction_history where transaction_id = %s) AND D.symbol = (SElecT symbol as symB from transaction_history where transaction_id = %s AND C.date = D.date)) as new_tab)) from (SElecT C.LTP as A, D.LTP as B from historical_data C, historical_data D where C.symbol = (SElecT symbol as symA from transaction_history where transaction_id = %s) AND D.symbol = (SElecT symbol as symB from transaction_history where transaction_id = %s AND C.date = D.date)) as new_tab) / (SElecT risk_level from performance_metrics where transaction_id = %s)*(SElecT risk_level from performance_metrics where transaction_id = %s)) as correlation;'''
        values = [ID1, ID2, ID1, ID2, ID1, ID2, ID1, ID2]
        cur.execute(query, values)
        rv = cur.fetchall()
        return render_template('correl.html', values=rv)
    return render_template('calc_correl.html')

@app.route('/add_watchlist.html', methods=['GET', 'POST'])
def add_watchlist():

    # Query for companies (for drop down menu) excluding those which are already in watchlist
    cur = mysql.connection.cursor()
    query_companies = '''SElecT symbol from company_profile
where symbol not in
(select symbol from watchlist
where username = %s);
'''
    user = [session['user']]
    cur.execute(query_companies, user)
    companies = cur.fetchall()

    if request.method == 'POST':
        watchlist_details = request.form
        symbol = watchlist_details['symbol']
        cur = mysql.connection.cursor()
        query = '''insert into watchlist(username, symbol) values
(%s, %s)'''
        values = [session['user'], symbol]
        cur.execute(query, values)
        mysql.connection.commit()
    return render_template('add_watchlist.html', companies=companies)

@app.route('/delete_watchlist.html', methods=['GET', 'POST'])
def delete_watchlist():

    # Query for companies (for drop down menu) which are already in watchlist
    cur = mysql.connection.cursor()
    query_companies = '''SElecT symbol from company_profile
where symbol in
(select symbol from watchlist
where username = %s);
'''
    user = [session['user']]
    cur.execute(query_companies, user)
    companies = cur.fetchall()

    if request.method == 'POST':
        watchlist_details = request.form
        symbol = watchlist_details['symbol']
        cur = mysql.connection.cursor()
        query = '''delete from watchlist where username = %s AND symbol = %s'''
        values = [user, symbol]
        cur.execute(query, values)
        mysql.connection.commit()
    return render_template('delete_watchlist.html', companies=companies)

@app.route('/stockprice.html')
def current_price(company='all'):
    cur = mysql.connection.cursor()
    if company == 'all':
        query = '''SElecT date, symbol, LTP, PC FROM historical_data
order by date;
'''
        cur.execute(query)
    else:
        company = [company]
        query = '''SElecT date, symbol, LTP, PC FROM historical_data
        where symbol = %s order by date;
'''
        cur.execute(query, company)
    rv = cur.fetchall()
    return render_template('stockprice.html', values=rv)


@app.route('/fundamental.html', methods=['GET'])
def fundamental_report(company='all'):
    cur = mysql.connection.cursor()
    if company == 'all':
        query = '''select * from  fundamental_averaged;'''
        cur.execute(query)
    else:
        company = [company]
        query = '''select F.symbol, report_as_of, LTP, eps, roe, book_value, round(LTP/eps, 2) as pe_ratio
from fundamental_report F
inner join company_price C
on F.symbol = C.symbol
where F.symbol = %s'''
        cur.execute(query, company)
    rv = cur.fetchall()
    return render_template('fundamental.html', values=rv)


@app.route('/technical.html')
def technical_analysis(company='all'):
    cur = mysql.connection.cursor()
    if company == 'all':
        query = '''select A.symbol, sector, LTP, volume, RSI, ADX, MACD from technical_signals A 
left join company_profile B
on A.symbol = B.symbol
order by (A.symbol)'''
        cur.execute(query)
    else:
        company = [company]
        query = '''SElecT * FROM technical_signals where company = %s'''
        cur.execute(query, company)
    rv = cur.fetchall()
    return render_template('technical.html', values=rv)


@app.route('/companyprofile.html')
def company_profile(company='all'):
    cur = mysql.connection.cursor()
    if company == 'all':
        query = '''select * from company_profile
order by(symbol);
'''
        cur.execute(query)
    else:
        company = [company]
        query = '''select * from company_profile where company = %s'''
        cur.execute(query, company)
    rv = cur.fetchall()
    return render_template('companyprofile.html', values=rv)

@app.route('/financial.html')
def financial_info(date='all'):
    cur = mysql.connection.cursor()
    if date == 'all':
        query = '''select * from financial_info'''
        cur.execute(query)
    else:
        date = [date]
        query = '''select * from financial_info where date = %s'''
        cur.execute(query, date)
    rv = cur.fetchall()
    return render_template('financial.html', values=rv)
# @app.route('/dividend.html')
# def dividend_history(company='all'):
#     cur = mysql.connection.cursor()
#     if company == 'all':
#         query = '''select * from dividend_history
# order by(symbol);
# '''
#         cur.execute(query)
#     else:
#         company = [company]
#         query = '''select * from dividend_history where company = %s'''
#         cur.execute(query, company)
#     rv = cur.fetchall()
#     return render_template('dividend.html', values=rv)


@app.route('/watchlist.html')
def watchlist():
    if 'user' not in session:
        return render_template('alert1.html')
    cur = mysql.connection.cursor()
    query_watchlist = '''select symbol, LTP, PC, round((LTP-PC), 2) AS CH, round(((LTP-PC)/PC)*100, 2) AS CH_percent from watchlist
natural join company_price
where username = %s
order by (symbol);
'''
    cur.execute(query_watchlist, [session['user']])
    watchlist = cur.fetchall()

    return render_template('watchlist.html', user=session['user'], watchlist=watchlist)


@app.route('/holdings.html')
def holdings():
    if "user" not in session:
        return render_template('alert1.html')
    cur = mysql.connection.cursor()
    query_holdings = '''select A.symbol, A.quantity, B.LTP, round(A.quantity*B.LTP, 2) as current_value from holdings_view A
inner join company_price B
on A.symbol = B.symbol
where username = %s
'''
    cur.execute(query_holdings, [session['user']])
    holdings = cur.fetchall()

    return render_template('holdings.html', user=session['user'], holdings=holdings)

@app.route('/news.html')
def news(company='all'):
    cur = mysql.connection.cursor()
    if company == 'all':
        query = '''select date_of_news, title, related_company, C.sector, group_concat(sources) as sources 
from news N
inner join company_profile C
on N.related_company = C.symbol
group by(title);
'''
        cur.execute(query)
    else:
        company = [company]
        query = '''select date_of_news, title, related_company, related_sector, sources from news where related_company = %s'''
        cur.execute(query, company)
    rv = cur.fetchall()
    return render_template('news.html', values=rv)


if __name__ == '__main__':
    app.run(debug=True)
