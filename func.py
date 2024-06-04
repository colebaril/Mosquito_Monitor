#!/usr/bin/env python
# coding: utf-8

# # Funções

# ## Importing libs

import os
import requests
import tweepy
from datetime import datetime as dt

# ## Auth

tt = tweepy.Client(
    #Consumer Keys
    consumer_key= os.environ['CONSUMER_KEY'],
    consumer_secret= os.environ['CONSUMER_SECRET'],
    # Access Token and Secret
    access_token= os.environ['ACCESS_TOKEN'],
    access_token_secret= os.environ['ACCESS_TOKEN_SECRET'])

# ## Defining Functions

now = dt.now()

#- get_date()
def get_date(year=None, month=None, day=None, now=now, as_str=True):
    """Returns string with the actual month and year, or especified date.
  Used in request url.

  in: get_month()
  out: <ACTUAL_YEAR>/<ACTUAL_MONTH>/

  in: get_month(year = 2010, month = 03)
  out: 2010/marco"""

    if year == None:
        year_n = now.year
    else:
        year_n = year

    if month == None:
        month_n = now.month
    else:
        month_n = month

    day_n = now.day

    dt_month = dict(
        zip(range(1, 13), [
            'janeiro', 'fevereiro', 'marco', 'abril', 'maio', 'junho', 'julho',
            'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
        ]))

    if as_str == True:
        str_date = '{}/{}'.format(year_n, dt_month[month_n])
    else:
        str_date = [year_n, month_n, day_n]

    return str_date


#- create_tree()
def create_tree(year=None, month=None):

    # sets month and year for request ()
    str_date = get_date(year, month)

    # Scrap's Resquest
    url_r = 'https://www.datascomemorativas.me/{}'.format(str_date)
    with requests.get(url_r) as r:
        #print('DEBUG - status code: ',r.status_code)
        r.encoding = 'UTF-8'
        text = r.text  # string
        #content = r.content # bytes

    # generates html tree from html string
    from lxml import html
    tree = html.fromstring(text)
    return tree


#- create_grid()
def create_grid(year=None, month=None, full_grid=False):

    # today's date
    today = get_date(as_str=False)

    if year == None:
        year = today[0]

    month_n = today[1] if month == None else month

    html_tree = create_tree(year, month)

    x = list(range(1, 7))  # week of the month (1 = first week)
    y = list(range(1, 8))  # day of the week (1 = sunday, 7 = saturday)
    z = list(range(
        1, 10))  # 9 rows per day (row1: icecream day, row2: youscream day)

    # Creates Grid
    from itertools import product
    l = list(product(x, y, z))  # Vectorial product of lists

    # Sets up grid loop
    content = None
    date_list = []

    # defines year
    year_xpath = '/html/body/section/div/header/div[1]/span[2]'
    year = int(html_tree.xpath(year_xpath)[0].text_content())

    # defines month
    month_xpath = '/html/body/section/div/header/div[1]/span[1]'
    month = html_tree.xpath(month_xpath)[0].text_content()

    # Searchs html-tree using the grid
    for x in range(len(l)):
        a, b, c = l[x][0], l[x][1], l[x][2]
        xpath_ref = [a, b, c]
        # If a month starts on monday (week day 2), then the Sunday (day =1) returns Day = None
        try:
            #Defines day
            day_xpath = '/html/body/section/div/div/table/tbody/tr[{0}]/td[{1}]/div[1]/span[1]'.format(
                a, b)
            day = html_tree.xpath(day_xpath)[0].text_content()
        except:
            day = 0



        try:
            content_xpath = '/html/body/section/div/div/table/tbody/tr[{0}]/td[{1}]/ul/li[{2}]/span'.format(
                a, b, c)
            content = html_tree.xpath(content_xpath)[0].text_content()
        except:
            content = None

        # Verifica se é um feriado!
        if content == None:
            try:
                content_xpath = '/html/body/section/div/div/table/tbody/tr[{0}]/td[{1}]/ul/li[{2}]/a'.format(
                a, b, c)
                content = html_tree.xpath(content_xpath)[0].text_content()
                feriado_str = 'feriado!⭐ '
                content = feriado_str+content
            except:
                content = None           

        date_list.append([year, month_n, int(day), content, str(xpath_ref)])

        if full_grid == False:
            date_list = [x for x in date_list if x[3] != None
                         ]  # Filters grid: content != None. See *** bellow

    return date_list


#- todays_tt()
def todays_tt():
    today = get_date(as_str=False)
    date_list = create_grid()
    tt_list = [x for x in date_list if x[:3] == today]

    return tt_list

#- create_tree_feriado
def create_tree_feriado(year=None, month=None, url = 'http://www.supercalendario.com.br/feriados/'):

    # sets month and year for request ()
    str_date = get_date(year, month)[:4]

    # Scrap's Resquest
    url_r = url+'{}'.format(str_date)
    #print(url_r)
    with requests.get(url_r) as r:
        #print('DEBUG - status code: ',r.status_code)
        r.encoding = 'UTF-8'
        text = r.text  # string
        #content = r.content # bytes

    # generates html tree from html string
    from lxml import html
    tree = html.fromstring(text)
    return tree

#- get_list_feriado_futuro()
def get_list_feriado_futuro(year = None, now = now):
    
    today = now.date()
    
    if year == None:
        year = now.year
    #print('feriados de ', year)
    
    url_feriado = 'http://www.supercalendario.com.br/feriados/'
    tree = create_tree_feriado(year = year, url = url_feriado)

    list_contents = [y.split(' - ') for y in [x.text_content() for x in tree.find_class('holidayDate')[1:]]]
    list_feriado  = [f[0] for f in list_contents]
    list_wd       = [f[1] for f in list_contents]
    list_content  = [f[2] for f in list_contents]
    
    
    from pandas import to_datetime
    from dateutil.relativedelta import relativedelta

    rd = (relativedelta(years = year) - relativedelta(years = 1900))  
    list_feriado = [(to_datetime(f, format='%d/%m') + rd).date() for f in list_feriado]
    list_distancia_feriado = [(d - today).days for d in list_feriado]
    list_feriados_futuro = [x for x in list_distancia_feriado if x>0]
    
    if  len(list_feriados_futuro) == 0:
        print('DEBUG: feriados de year+1')
        return get_list_feriado_futuro(year = year+1)
           
    next_holiday_in_days = min(list_feriados_futuro)
    next_holiday_idx = list_distancia_feriado.index(next_holiday_in_days)
    
    list_content = [list_feriado[next_holiday_idx], list_wd[next_holiday_idx], list_content[next_holiday_idx], next_holiday_in_days]
    
    return list_content

#- get_content_feriado()
def get_content_feriado(year = None, now = now):

    list_content = get_list_feriado_futuro(year=year, now = now)
    feriado  = list_content[0]
    wd       = list_content[1]
    content  = list_content[2]
    
    next_holiday_in_days = list_content[3]
    
    dt_month = dict(
            zip(range(1, 13), [
                'janeiro', 'fevereiro', 'marco', 'abril', 'maio', 'junho', 'julho',
                'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
            ]))

    str_dt_feriado = feriado.strftime(f'%d de {dt_month[feriado.month]} de %Y')
    str_content_feriado = f"\nFaltam {next_holiday_in_days} dias para o próximo feriado: O {content}, em {str_dt_feriado}!"
    extra_feriado = "\nE se prepara pro feriadão que o {} cai numa {}!🌞😎".format(content, wd)

    if wd in ["Segunda-feira","Sexta-feira"]:
        str_content_feriado = str_content_feriado+extra_feriado
    
    #print(str_content_feriado)
    return str_content_feriado

#- format_post()
def format_post():
    ttt = todays_tt()
    ttt_aux = list(set([x[3] for x in ttt]))
    txt = str([x for x in ttt_aux]).strip('[]').replace("'", "")

    if len(ttt_aux) > 1:
        txt = txt.replace(',{}'.format(txt.split(',')[-1]),
                          ' e{}'.format(txt.split(',')[-1]))
        
    # Carrega texto sobre o próximo feriado!   
    str_feriados = get_content_feriado()

    
    # - Substitui texto específico
    txt = txt.replace('Dia do Deficiente Físico','Dia da Pessoa com Deficência Física')
    txt = txt.replace('Dia do índio','Dia dos Povos indígenas')

    if txt == '':
        return '\nHoje não temos datas comemorativas! 😥 ' + str_feriados
    else:
        return '\n\nHoje é {}.'.format(txt) + str_feriados


#- post_date()
def post_date():
    text = format_post()
    print(text)
    r = tt.create_tweet(text=text)
    print(r)
    return
