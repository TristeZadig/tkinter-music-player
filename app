# -*- coding: utf-8 -*-
"""
Created on Mon Jun 30 20:55:53 2025

@author: mmina
"""

import tkinter as tk
from tkinter import filedialog
from PIL import ImageTk, Image
import pygame
from mutagen.mp3 import MP3

class MusicPlayerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Music Player")
        self.root.geometry("300x370")

#        self.root.overrideredirect(True)
#        self.root.lift()
#        self.root.wm_attributes("-topmost", True)
#        self.root.wm_attributes("-disabled", True)
#        self.root.config(bg='white')
#        self.root.wm_attributes("-transparentcolor", "white")
        
        pygame.init()
        pygame.mixer.init()
        
        # État de la musique (0 = arrêtée, 1 = en marche, 2 = en pause)
        self.is_playing = 0
        self.progress_value = 0
        self.is_user_seeking = False
        self.mycolor = 'whitesmoke'
        
        # Widgets Tkinter
        self.label = tk.Label(root, text="Choisissez un fichier audio", font=("Arial", 14))
        self.label.pack(pady=20)
        
        self.path = Image.open("./PIC/PIC.png").resize((200, 200), Image.NEAREST)
        self.img = ImageTk.PhotoImage(self.path)
        self.music_image = tk.Label(root, image = self.img)
        self.music_image.image = self.img 			## Maintient en vie de self.img dans un objet non détruit par le garbage
        self.music_image.place(x=50, y=60)
        
        self.path = Image.open("./PIC/Cadre.png").resize((200, 73), Image.NEAREST)
        self.img = ImageTk.PhotoImage(self.path)
        self.music_image = tk.Label(root, image = self.img)
        self.music_image.image = self.img 			## Maintient en vie de self.img dans un objet non détruit par le garbage
        self.music_image.place(x=50, y=270)
        
        self.open_button = tk.Button(root, command=self.open_file, bg=self.mycolor)
        self.pathOB = Image.open("./PIC/Menu.png").resize((30, 30), Image.BOX)
        self.img = ImageTk.PhotoImage(self.pathOB)
        self.open_button_image = self.img
        self.open_button.config(image=self.open_button_image, borderwidth=0)
        self.open_button.place(x=60, y=290)
        
        self.play_pause_button = tk.Button(root, text="Lancer", command=self.play_pause_music, bg=self.mycolor, state=tk.DISABLED)
        self.pathPLAY = Image.open("./PIC/Play_button.png").resize((50, 50), Image.LANCZOS)
        self.img = ImageTk.PhotoImage(self.pathPLAY)
        self.play_button_image = self.img
        self.play_pause_button.config(image=self.play_button_image, borderwidth=0)
        self.play_pause_button.place(x=124, y=280)

        #on définit ici pour la suite self.pause_button_image pour stocker l'image "pause"
        self.pathPAUSE = Image.open("./PIC/Pause_button.png").resize((50, 50), Image.LANCZOS)
        self.img = ImageTk.PhotoImage(self.pathPAUSE)
        self.pause_button_image = self.img
        
        self.stop_button = tk.Button(root, text="Arrêter", command=self.stop_music, bg=self.mycolor, state=tk.DISABLED)
        self.pathSB = Image.open("./PIC/OFF.png").resize((30, 30), Image.HAMMING)
        self.img = ImageTk.PhotoImage(self.pathSB)
        self.stop_button_image = self.img
        self.stop_button.config(image=self.stop_button_image, borderwidth=0)
        self.stop_button.place(x=207, y=290)        

        
        self.var = tk.DoubleVar()
        self.scale = tk.Scale(root, orient=tk.HORIZONTAL, variable=self.var, from_=0, to=100, length=180, showvalue=0, tickinterval=0.25)
        self.scale.bind("<ButtonRelease-1>", self.music_position)
        self.scale.place(x=60, y=220)
        
        self.filepath = None
        
        self.total_duration = 0
        self.new_time = 0
        self.root.after(1000, self.update_playback_time) # si on ne met que ça, self.update_playback_time() ca fait une division par 0 parceque la fct est appelée tout de suite

    def open_file(self):
        self.filepath = filedialog.askopenfilename(filetypes=[("Fichiers audio", "*.mp3 *.wav")])
        if self.filepath:
            self.label.config(text=f"Fichier sélectionné : {self.filepath.split('/')[-1]}")
            self.play_pause_button.config(state=tk.NORMAL)

            if self.filepath.endswith(".mp3"):
                audio = MP3(self.filepath)
                self.total_duration = int(audio.info.length)
            else:
                sound = pygame.mixer.Sound(self.filepath)
                self.total_duration = int(sound.get_length())
                
    def sound_start(self, time):
        pygame.mixer.music.load(self.filepath)
        pygame.mixer.music.play(0, time)

    def play_pause_music(self):
        if not self.filepath:
            return
        
        if self.is_playing == 1 :
            pygame.mixer.music.pause()
            self.play_pause_button.config(image=self.play_button_image, borderwidth=0) #mode pause
            self.is_playing = 2
            
        else:
            if self.is_playing == 2 :
                pygame.mixer.music.unpause()

            else:
                self.sound_start(0)
            self.play_pause_button.config(image=self.pause_button_image, borderwidth=0)
            self.is_playing = 1
        self.stop_button.config(state=tk.NORMAL)

    def stop_music(self):
        pygame.mixer.music.stop() #marche aussi avec music.stop
        self.play_pause_button.config(text="Lancer", state=tk.DISABLED)
        self.stop_button.config(state=tk.DISABLED)
        self.is_playing = 0
        self.scale.set(0)
        self.label.config(text="Choisissez un fichier audio")
        self.new_time = 0
        
        
    def update_playback_time(self):
        if self.is_playing and self.total_duration > 0 : #and not self.is_user_seeking
            playback_position = self.new_time + pygame.mixer.music.get_pos() // 1000  # Convert milliseconds to seconds

         # Update progress bar
            self.progress_value = (playback_position / self.total_duration) * 100
            self.scale.set(self.progress_value)

        self.root.after(1000, self.update_playback_time)  # Update every second 
        
        
    def music_position(self, event):
        position = self.scale.get()
        self.new_time = position * self.total_duration / 100
        self.sound_start(self.new_time)

# Lancer l'application
if __name__ == "__main__":
    root = tk.Tk()
    app = MusicPlayerApp(root)
    root.mainloop()
