    query = '''SELECT symbol, company_name, LTP, sector, quantity, risk_level from company_price NATURAL JOIN company_profile NATURAL JOIN transaction_history NATURAL JOIN performance_metrics order by risk_level LIMIT 5;'''
