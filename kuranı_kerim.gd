extends Node2D

var BakilanSayfa : int = 0
var last_click_time = 0.0
var double_click_threshold = 0.2  # saniye cinsinden, iki tıklama arası maksimum süre

var gunes = load("res://icon/sun.png")
var ay = load("res://icon/moon.png")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and $SayfaAnimationPlayer.is_playing() == false:
		var now = Time.get_ticks_msec() / 1000.0  # milisaniyeyi saniyeye çeviriyoruz
		if now - last_click_time < double_click_threshold:
			_on_double_click()
		last_click_time = now
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pass

func Kayıt():
	var veri = {
		"sayfa": int(BakilanSayfa),
		"tema": bool($"Control/Karanlık".visible) ,
	}

	var json_string = JSON.stringify(veri)

	var dosya = FileAccess.open("user://kuranı_kerim.json", FileAccess.WRITE)
	dosya.store_string(json_string)
	dosya.close()
	print("Sahne kaydedildi.")

func Yukleme():
	if not FileAccess.file_exists("user://kuranı_kerim.json"):
		print("Kayıt dosyası yok.")
		return

	var dosya = FileAccess.open("user://kuranı_kerim.json", FileAccess.READ)
	var veri = JSON.parse_string(dosya.get_as_text())
	dosya.close()

	if typeof(veri) == TYPE_DICTIONARY:
		BakilanSayfa = int(veri["sayfa"])
		$"Control/Karanlık".visible = bool(veri["tema"])
		print("Sahne yüklendi.")

func _on_double_click():
	$menu.visible = !$menu.visible
	$Control/SayfaDegis.visible = !$Control/SayfaDegis.visible
	if $menu.visible == false :
		$MenuAnimationPlayer.play("UstMenüKapanma")
	else:
		$MenuAnimationPlayer.play("UstMenüKapanma",-1,-1.0,true)

func _ready() -> void:
	Yukleme()
	SayfalariYukleme()
	Tema_tus_kontrol()

func _process(_delta: float):

	if $Control/SayfaDegis.value == 0 :
		$Control/SayfaDegis.visible = false
		$Control/SayfaDegis.value = 1
		SayfaDegis("sol")

	elif $Control/SayfaDegis.value == 70 :
		$Control/SayfaDegis.visible = false
		$Control/SayfaDegis.value = 69
		SayfaDegis("sag")

func SayfaDegis(Nere):
	if Nere == "sol":
		BakilanSayfa += 1
		if BakilanSayfa > 604 :
			BakilanSayfa = 0
		$SayfaAnimationPlayer.play("SayfaDegisSol")
	elif Nere == "sag" :
		BakilanSayfa -= 1
		if BakilanSayfa < 0 :
			BakilanSayfa = 604
		$SayfaAnimationPlayer.play("SayfaDegisSag")
		
	$Control/SayfaDegis.visible = true
	Kayıt()

func SayfalariYukleme():
	
	var degis0
	var degis2
	if BakilanSayfa == 0 :
		degis0 = load("res://Kuranı-Kerim/604.png")
	else :
		degis0 = load("res://Kuranı-Kerim/%d.png" % (BakilanSayfa-1))

	if BakilanSayfa == 604 :
		degis2 = load("res://Kuranı-Kerim/0.png")
	else :
		degis2 = load("res://Kuranı-Kerim/%d.png" % (BakilanSayfa+1))

	var degis1 = load("res://Kuranı-Kerim/%d.png" % BakilanSayfa)
	
	$Control/OncekiSayfa.texture = degis0
	$Control/BakilanSayfa.texture = degis1
	$Control/SonrakiSayfa.texture = degis2

func _on_sure_secim_item_selected(index: int) -> void:
	BakilanSayfa = Genel.Sureler[$menu/ColorRect/SureSecim.get_item_text(index)]
	SayfalariYukleme()
	Kayıt()

func _on_karanlık_tema_pressed() -> void:
	if $"menu/ColorRect/KaranlıkTema".icon == gunes :
		$"menu/ColorRect/KaranlıkTema".icon = ay
		$"Control/Karanlık".visible = false
	else :
		$"menu/ColorRect/KaranlıkTema".icon = gunes
		$"Control/Karanlık".visible = true
	Kayıt()

func Tema_tus_kontrol() -> void :
	if $"Control/Karanlık".visible == true:
		$"menu/ColorRect/KaranlıkTema".icon = gunes
	else:
		$"menu/ColorRect/KaranlıkTema".icon = ay

func _on_geri_pressed() -> void:
	$SayfaDegisTusAnimationPlayer.play("Geri")


func GeriGitme() -> void:
	get_tree().change_scene_to_file("res://namaz_vakti.tscn")
	
