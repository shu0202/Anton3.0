import sys
from PyQt5.QtWidgets import QApplication, QMainWindow, QWidget, QVBoxLayout, QPushButton, QHBoxLayout, QLineEdit, QLabel
from PyQt5.QtGui import QPainter, QPen, QFont
from PyQt5.QtCore import Qt

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

        # Draw staff lines
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
            note_y = (self.staff_lines - 1 - note) * self.note_spacing + 30
            note_pos = self.note_positions[note % len(self.note_positions)]
            painter.drawText(80 + i * 60, note_y, note_pos)

    def set_note_position(self, index, position):
        if 0 <= index < len(self.notes):
            self.notes[index] = position
            self.update()

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.staff = None
        self.note_buttons_layout = QVBoxLayout()
        self.initUI()

    def initUI(self):
        self.setWindowTitle('Adjustable Staff Notes')

        self.num_notes_input = QLineEdit()
        self.num_notes_input.setPlaceholderText('Enter number of notes')

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

    def create_notes(self):
        if self.staff:
            self.staff.setParent(None)
            self.staff.deleteLater()
            self.staff = None

        # Clear all items from the note buttons layout
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

        # Create note control buttons in rows
        row_layout = QHBoxLayout()
        for i in range(num_notes):
            plus_button = QPushButton('+')
            minus_button = QPushButton('-')
            plus_button.setFixedSize(30, 30)
            minus_button.setFixedSize(30, 30)

            plus_button.clicked.connect(lambda _, idx=i: self.move_note_up(idx))
            minus_button.clicked.connect(lambda _, idx=i: self.move_note_down(idx))

            button_label = QLabel(f'Note {i + 1}')

            button_layout = QHBoxLayout()
            button_layout.addWidget(minus_button)
            button_layout.addWidget(button_label)
            button_layout.addWidget(plus_button)
            button_layout.setContentsMargins(0, 0, 0, 0)
            button_layout.setSpacing(5)

            note_button_widget = QWidget()
            note_button_widget.setLayout(button_layout)
            row_layout.addWidget(note_button_widget)

            # Add the row to the main layout and start a new row after every 3 widgets
            if (i + 1) % 3 == 0 or i == num_notes - 1:
                self.note_buttons_layout.addLayout(row_layout)
                row_layout = QHBoxLayout()

    def _clear_layout(self, layout):
        """Helper function to clear a layout and delete its children."""
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
            print(f"Note {index + 1} position: {new_position}")

    def move_note_up(self, index):
        if self.staff and 0 <= index < len(self.staff.notes):
            new_position = min(self.staff.notes[index] + 1, self.staff.staff_lines - 1)
            self.staff.set_note_position(index, new_position)
            print(f"Note {index + 1} position: {new_position}")


if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())
