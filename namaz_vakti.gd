extends Node2D

var Text_Yazilari
var Gunler_vakitler = []
var Bugunku_vakitler
var Yarinki_vakitler
var regex = RegEx.new()

var Vakitler = []
var YarinkiVakitler = []

var hicri_takvim
var imsak_vakti
var gunes_vakti
var ogle_vakti
var ikindi_vakti
var aksam_vakti
var yatsi_vakti
var yarinki_imsak_vakti

var menu = true

const Aylar = {
	1 : "Ocak" ,
	2 : "Şubat",
	3 : "Mart",
	4 : "Nisan",
	5 : "Mayıs",
	6 : "Haziran",
	7 : "Temmuz",
	8 : "Ağustos",
	9 : "Eylül",
	10 : "Ekim",
	11 : "Kasım",
	12 : "Aralık",
}

func _ready():

	Gunluk_Vakti_Bulma_ve_Ayırma()

	#print(Vakitler)
	#print(YarinkiVakitler)
	#print(Bugunku_vakitler)
	#print(Gunler_vakitler)
	#print(Yarinki_vakitler)

func _process(_delta):

	var saat = Time.get_time_dict_from_system()
	$Control/Saat.text = " Saat: %s:%s:%s" % [basına_sıfır_ekle(saat.hour), basına_sıfır_ekle(saat.minute), basına_sıfır_ekle(saat.second)]
	
	var tarih = Time.get_date_dict_from_system()
	$Control/Tarih.text = "Tarih: %s:%s:%d " % [basına_sıfır_ekle(tarih.day), basına_sıfır_ekle(tarih.month), tarih.year]
	
	if saat.hour == 0 and saat.minute == 0 and saat.second == 0:
		Gunluk_Vakti_Bulma_ve_Ayırma()
	
	if vakitler_arası_fark(imsak_vakti) :
		$Control/Vakte_Kalan.text = saniye_cinsinden_saati_cevirme(vakitler_arası_fark(imsak_vakti))
		$Control/Hangi_Vakte_Kalan.text = "İmsak Vaktine Kalan"
	elif vakitler_arası_fark(gunes_vakti) : 
		$Control/Vakte_Kalan.text = saniye_cinsinden_saati_cevirme(vakitler_arası_fark(gunes_vakti))
		$Control/Hangi_Vakte_Kalan.text = "Güneş Vaktine Kalan"
	elif vakitler_arası_fark(ogle_vakti) : 
		$Control/Vakte_Kalan.text = saniye_cinsinden_saati_cevirme(vakitler_arası_fark(ogle_vakti))
		$Control/Hangi_Vakte_Kalan.text = "Öğle Vaktine Kalan"
	elif vakitler_arası_fark(ikindi_vakti) : 
		$Control/Vakte_Kalan.text = saniye_cinsinden_saati_cevirme(vakitler_arası_fark(ikindi_vakti))
		$Control/Hangi_Vakte_Kalan.text = "İkindi Vaktine Kalan"
	elif vakitler_arası_fark(aksam_vakti) : 
		$Control/Vakte_Kalan.text = saniye_cinsinden_saati_cevirme(vakitler_arası_fark(aksam_vakti))
		$Control/Hangi_Vakte_Kalan.text = "Akşam Vaktine Kalan"
	elif vakitler_arası_fark(yatsi_vakti) : 
		$Control/Vakte_Kalan.text = saniye_cinsinden_saati_cevirme(vakitler_arası_fark(yatsi_vakti))
		$Control/Hangi_Vakte_Kalan.text = "Yatsi Vaktine Kalan"
	else :
		$Control/Vakte_Kalan.text = saniye_cinsinden_saati_cevirme(vakitler_arası_fark(yarinki_imsak_vakti))
		$Control/Hangi_Vakte_Kalan.text = "İmsak Vaktine Kalan"

func Gunluk_Vakti_Bulma_ve_Ayırma() -> void:

	var tarih = Time.get_date_dict_from_system()
	var file_path = "res://Namaz Vakti.txt"
	var file = FileAccess.open(file_path, FileAccess.READ)

	#regex.compile(r"\b02 Aralık\b")  # "oyun" kelimesini arar (kelime sınırlarıyla)
	regex.compile(r"{Gun} {Ay} {Yıl}\b".format({"Gun": basına_sıfır_ekle(tarih.day), "Ay": Aylar[tarih.month], "Yıl": tarih.year}))
	
	if file:
		Text_Yazilari = file.get_as_text()
		file.close()
	else:
		print("Dosya açılamadı: ", file_path)
	var Gunluk_vakit = ""

	for i in Text_Yazilari:
		if i == "\n" :
			Gunluk_vakit += " "
			Gunler_vakitler.append(Gunluk_vakit)
			Gunluk_vakit = ""
		else :
			Gunluk_vakit += i

	var bayrak = false
	for i in Gunler_vakitler:

		if bayrak :
			bayrak = false
			Yarinki_vakitler = i

		if regex.search_all(i) :
			Bugunku_vakitler = i
			bayrak = true
	
	var Kelime = ""
	var Kelime1 = ""
	Vakitler = []
	YarinkiVakitler = []

	for i in Bugunku_vakitler :
		if i  == " ":
			Vakitler.append(Kelime)
			Kelime = ""
		else :
			Kelime += i

	for i in Yarinki_vakitler :
		if i  == " ":
			YarinkiVakitler.append(Kelime1)
			Kelime1 = ""
		else :
			Kelime1 += i
	
	imsak_vakti = string_saati_ayirarak_inte_cevirme(Vakitler[7])
	gunes_vakti =  string_saati_ayirarak_inte_cevirme(Vakitler[8])
	ogle_vakti = string_saati_ayirarak_inte_cevirme(Vakitler[9])
	ikindi_vakti = string_saati_ayirarak_inte_cevirme(Vakitler[10])
	aksam_vakti = string_saati_ayirarak_inte_cevirme(Vakitler[11])
	yatsi_vakti = string_saati_ayirarak_inte_cevirme(Vakitler[12])
	yarinki_imsak_vakti = string_saati_ayirarak_inte_cevirme(YarinkiVakitler[7]) 
	
	$Control/Hicri_takvim.text = Vakitler[4] + " " + Vakitler[5] + " " + Vakitler[6]
	
	$"Control/Vakitler/İmsak".text = Vakitler[7]
	$Control/Vakitler/Gunes.text = Vakitler[8]
	$Control/Vakitler/Ogle.text = Vakitler[9]
	$"Control/Vakitler/İkındı".text = Vakitler[10]
	$Control/Vakitler/Aksam.text = Vakitler[11]
	$"Control/Vakitler/Yatsı".text = Vakitler[12]

func vakitler_arası_fark(vakit):
	var saat = Time.get_time_dict_from_system()
	var saniye_cinsi_saat = saat_cinsinden_saniye_cevirme(saat)
	if saniye_cinsi_saat > yatsi_vakti and vakit == yarinki_imsak_vakti :
		return (86400 + vakit) - saniye_cinsi_saat
	elif vakit - saniye_cinsi_saat > 0:
		return vakit - saniye_cinsi_saat
	else :
		return false 

func basına_sıfır_ekle(sayi):
	if sayi <= 9 :
		return "0%s" % sayi
	else:
		return sayi

func saniye_cinsinden_saati_cevirme(Saniye: int):

	var saat = Saniye / 3600  # Toplam saat
	var dakika = (Saniye % 3600) / 60  # Saatten kalan dakikalar
	var saniye = Saniye % 60  # Kalan saniyeler
	
	return "%02d:%02d:%02d" % [saat, dakika, saniye]

func saat_cinsinden_saniye_cevirme(saat):
	return saat.hour * 3600 + saat.minute * 60 + saat.second

func string_saati_ayirarak_inte_cevirme(saat): 
	var saniye : int
	var sayılar = ""
	for i in saat :
		if i == ":":
			saniye = int(sayılar) * 3600
			sayılar = ""
		else :
			sayılar += i
	saniye += int(sayılar) * 60
	return saniye

func _on_menu_pressed() -> void:
	if $Control/MenuArka.get_size() == Vector2(11,288):
		$AnimationPlayer.play("MenuAçma")
	else :
		$AnimationPlayer.play("MenuAçma",-1,-1.0,true)

func _on_zikirmatik_pressed() -> void:
	$AnimationPlayer.play("AçılışZikir")

func _on_kuranı_kerim_pressed() -> void:
	$AnimationPlayer.play("AçılışKuran")

func ZikirSahnesineGec() -> void:
	get_tree().change_scene_to_file("res://zikir.tscn")

func KuranSahnesiGec() -> void:
	get_tree().change_scene_to_file("res://kuranı_kerim.tscn")
	
