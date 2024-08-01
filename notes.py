import json
import sys
from PyQt5.QtWidgets import QApplication, QMainWindow, QWidget, QVBoxLayout, QPushButton, QHBoxLayout, QLineEdit, QLabel, QSizePolicy, QSpacerItem, QInputDialog
from PyQt5.QtGui import QPainter, QPen, QFont, QPixmap
from PyQt5.QtCore import Qt, QRect
import os


class StaffWidget(QWidget):
    def __init__(self, num_notes):
        super().__init__()
        self.note_positions = ['O']  # Added new note positions
        self.note_spacing = 13
        self.staff_lines = 10
        self.notes = [0] * num_notes
        self.initUI()

    def initUI(self):
        self.setMinimumSize(800, 200)  # Adjusted size for better fit

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setPen(QPen(Qt.black, 3))
        painter.setFont(QFont('Arial', 1))

        # Set the background color to white
        painter.fillRect(self.rect(), Qt.white)

        treble_clef = QPixmap("Treble.png")
        painter.drawPixmap(QRect(10, 0, 69, 172), treble_clef)

        for i in range(self.staff_lines):
            if i%2 == 0:
                y = i * self.note_spacing + 30
                painter.drawLine(20, y, self.width() - 20, y)
            else:
                y = (i-1) * self.note_spacing + 30
                painter.drawLine(20, y, self.width() - 20, y)

        # Draw notes
        for i, note in enumerate(self.notes):
            painter.setPen(QPen(Qt.black, 3))
            painter.setFont(QFont('Arial', 35))
            note_y = (self.staff_lines - 1 - note) * self.note_spacing + 42
            note_pos = self.note_positions[note % len(self.note_positions)]
            painter.drawText(80 + i * 60, note_y, note_pos)

    def set_note_position(self, index, position):
        if 0 <= index < len(self.notes):
            self.notes[index] = position
            self.update()

class NotesEditor(QMainWindow):
    def __init__(self):
        super().__init__()
        self.staff = None
        self.note_buttons_layout = QVBoxLayout()
        self.initUI()
        self.piece_dir = ''
        self.load_directories()
        print("Check: ")
        print(self.diagnose_dir)

    def initUI(self):
        self.setWindowTitle('Notes editor')

        button_style = """
            QPushButton {
                background-color: #4CAF50;
                color: white;
                padding: 10px 20px;
                border: none;
                border-radius: 5px;
            }
            QPushButton:hover {
                background-color: #3e8e41;
            }
        """

        self.num_notes_input = QLineEdit()
        self.num_notes_input.setPlaceholderText('Enter the number of notes')

        self.confirm_button = QPushButton('Confirm')
        self.confirm_button.clicked.connect(self.create_notes)

        layout = QVBoxLayout()
        layout.addWidget(QLabel('Number of Notes:'))
        layout.addWidget(self.num_notes_input)
        layout.addWidget(self.confirm_button)

        self.staff_container = QWidget()
        self.staff_container.setLayout(QVBoxLayout())
        self.staff_container.layout().setContentsMargins(0, 0, 0, 0)
        layout.addWidget(self.staff_container)

        layout.addLayout(self.note_buttons_layout)

        container = QWidget()
        container.setLayout(layout)
        self.setCentralWidget(container)

        confirm_button = QPushButton("Confirm")
        confirm_button.setStyleSheet(button_style)
        confirm_button.clicked.connect(self.confirm_mode)
        layout.addWidget(confirm_button)

    def create_notes(self):
        if self.staff:
            self.staff.setParent(None)
            self.staff.deleteLater()
            self.staff = None

        while self.note_buttons_layout.count() > 0:
            item = self.note_buttons_layout.takeAt(0)
            if item:
                widget = item.widget()
                if widget:
                    widget.setParent(None)
                    widget.deleteLater()
                layout = item.layout()
                if layout:
                    self._clear_layout(layout)

        try:
            num_notes = int(self.num_notes_input.text())
            if num_notes < 1:
                raise ValueError
        except ValueError:
            print("Please enter a valid positive integer.")
            return

        self.staff = StaffWidget(num_notes)
        self.staff_container.layout().addWidget(self.staff)

        row_layout = QHBoxLayout()
        for i in range(num_notes):
            plus_button = QPushButton('+')
            minus_button = QPushButton('-')
            plus_button.setFixedSize(30, 30)
            minus_button.setFixedSize(30, 30)

            plus_button.clicked.connect(lambda _, idx=i: self.move_note_up(idx))
            minus_button.clicked.connect(lambda _, idx=i: self.move_note_down(idx))

            button_label = QLabel(f'Note {i + 1}')
            button_label.setAlignment(Qt.AlignCenter)

            button_layout = QHBoxLayout()
            button_layout.addWidget(minus_button)
            button_layout.addWidget(button_label)
            button_layout.addWidget(plus_button)
            button_layout.setContentsMargins(100, 0, 100, 0)
            button_layout.setSpacing(2)

            note_button_widget = QWidget()
            note_button_widget.setLayout(button_layout)
            row_layout.addWidget(note_button_widget)

            if (i + 1) % 3 == 0 or i == num_notes - 1:
                self.note_buttons_layout.addLayout(row_layout)
                row_layout = QHBoxLayout()

    def _clear_layout(self, layout):
        while layout.count():
            item = layout.takeAt(0)
            widget = item.widget()
            if widget:
                widget.setParent(None)
                widget.deleteLater()
            child_layout = item.layout()
            if child_layout:
                self._clear_layout(child_layout)

    def move_note_down(self, index):
        if self.staff and 0 <= index < len(self.staff.notes):
            new_position = max(self.staff.notes[index] - 1, 0)
            self.staff.set_note_position(index, new_position)
            #print(f"Note {index + 1} position: {new_position}")

    def move_note_up(self, index):
        if self.staff and 0 <= index < len(self.staff.notes):
            new_position = min(self.staff.notes[index] + 1, self.staff.staff_lines)
            self.staff.set_note_position(index, new_position)
            #print(f"Note {index + 1} position: {new_position}")
    
    def load_directories(self):
        try:
            with open('directories.json', 'r') as f:
                data = json.load(f)
                self.generate_dir = data.get('generate_dir', '')
                self.diagnose_dir = data.get('diagnose_dir', '')
        except (FileNotFoundError, json.JSONDecodeError):
            self.generate_dir = ''
            self.diagnose_dir = ''
    
    def confirm_mode(self):
        notes_pos_arr = []
        if self.staff:
            note_pos = [self.staff.notes[i] for i in range(len(self.staff.notes))]
            #print("Note positions:")
            for i, pos in enumerate(note_pos):
                notes_pos_arr.append(pos)
                #print(f"Note {i+1}: {pos}")
            
            #print(notes_pos_arr)
            piece_name, ok = QInputDialog.getText(self, "Save Piece", "Enter the name of the piece:")
            if ok and piece_name:
                self.piece_dir = self.diagnose_dir + "/" + piece_name
                print(f"Piece Directory: {self.piece_dir}")
                with open(f"{self.piece_dir}", "w") as file:
                    file.write("mode(major).\n")
                    file.write("part(1).\n")
                    for i in range(len(notes_pos_arr)):
                        if notes_pos_arr[i] == 0:
                            file.write(f"choosenNote(1,{i+1},27).\n")
                        elif notes_pos_arr[i] == 1:
                            file.write(f"choosenNote(1,{i+1},29).\n")
                        elif notes_pos_arr[i] == 2:
                            file.write(f"choosenNote(1,{i+1},30).\n")
                        elif notes_pos_arr[i] == 3:
                            file.write(f"choosenNote(1,{i+1},32).\n")
                        elif notes_pos_arr[i] == 4:
                            file.write(f"choosenNote(1,{i+1},34).\n")
                        elif notes_pos_arr[i] == 5:
                            file.write(f"choosenNote(1,{i+1},36).\n")
                        elif notes_pos_arr[i] == 6:
                            file.write(f"choosenNote(1,{i+1},37).\n")
                        elif notes_pos_arr[i] == 7:
                            file.write(f"choosenNote(1,{i+1},39).\n")
                        elif notes_pos_arr[i] == 8:
                            file.write(f"choosenNote(1,{i+1},41).\n")
                        elif notes_pos_arr[i] == 9:
                            file.write(f"choosenNote(1,{i+1},42).\n")
                        elif notes_pos_arr[i] == 10:
                            file.write(f"choosenNote(1,{i+1},44).\n")
                    file.write(f"partTimeMax(P,{len(notes_pos_arr)}) :- part(P).\n")
                    file.write("style(solo).\n")
                print(f"Piece saved as {piece_name}")
            else:
                print("No piece name provided. Piece not saved.")


        else:
            print("No notes created yet.")

        self.close()


if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = NotesEditor()
    window.show()
    sys.exit(app.exec_())
