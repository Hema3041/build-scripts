import smtplib, ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import argparse
from mailerConfig import *

message = MIMEMultipart()

def sendMail(subject, body):
	message['From'] = SENDER
	message['To'] = RECEIVER
	#message['Cc'] = CARBONCOPY
	message['Subject'] = subject
	body = MIMEText(body)
	message.attach(body)
	server = None
	context = ssl.create_default_context()
	try:
		server = smtplib.SMTP(SMTP_SERVER, PORT)
		server.ehlo()
		server.starttls(context=context) # Secure the connection
		server.ehlo()
		server.login(SENDER, PASSWORD)	
		server.sendmail(SENDER, RECEIVER.split(','), message.as_string())
	except Exception as e:
		print(e)
	finally:
		server.quit() 

def main():
	'''parser = argparse.ArgumentParser(description='Hoags email-sender script')
	parser.add_argument('-s', '--subject', help='subject of the mail', required=True)
	parser.add_argument('-b', '--body', help='body of the mail', required=True)

	args = vars(parser.parse_args())
	subject = args['subject']
	body = args['body']
	'''
	subject = ''
	body=''
	with open(SUBJFILE, 'r') as f:
		subject = f.read()
	
	with open(BODYFILE, 'r') as f:
		body = f.read()
	
	sendMail(subject, body)
    
  
if __name__=="__main__":
	main()

