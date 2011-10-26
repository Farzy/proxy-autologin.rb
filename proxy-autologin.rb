#!/usr/bin/env ruby -KU

# Authentifie le poste courant sur le proxy web
# Auteur : Farzad FARID
# Date : 26/10/2011
# Licence : WTFPL

require "rubygems"
require "mechanize"
require "highline/import"

###########################################################################
# Configuration
USER = ENV["USER"]

###########################################################################
# Programme principal

agent = Mechanize.new
# Recherche automatique du proxy. C'est une ligne similaire à :
#       return "PROXY 10.45.17.156:8080";
wpad = agent.get("http://wpad/wpad.dat")
m = wpad.content.match(/PROXY +(?'host'(?:\d+\.){3}\d+):(?'port'\d+)/)
raise "Fichier d'autoconfiguration proxy wpad.dat incorrect ou impossible à analyser." if !m
# Configuration du proxy dans l'agent web
agent.set_proxy(m['host'], m['port'].to_i)

# Authentification sur le proxy
page = agent.get("http://www.google.com")
# Si l'on n'est pas authentifié on doit trouver dans la page le formulaire "loginform"
login_form = page.form_with(:name => "loginform")

if login_form # On est bien sur le formulaire du Proxy
	login_form["PROXY_SG_USERNAME"] = USER
	login_form["PROXY_SG_PASSWORD"] = ask("Mot de passe de #{USER} : ") { |q| q.echo = "*" }
	result = login_form.submit
	if result.forms.size == 1 && result.forms[0].name == "f" # "f" est le nom du formulaire de google.com
		puts "Authentification sur le proxy réussie"
	else
		puts "ERREUR : L'authentification sur le proxy a échoué"
	end
else # Déjà authentifié
	puts "Vous êtes déjà authentifié(e) sur le proxy"
end
