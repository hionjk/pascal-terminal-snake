program snake_game;

uses
	crt;

const
  minFieldWidth = 8;
  minFieldHeight = 8;
  
  stdInputColor = LightRed;
  stdPrintColor = LightGreen;

	delayDuration = 75;
	
	maxFoodSatiation = 3;
	maxStyleId = 3;
	
type

	TVector = record
		x: integer;
		y: integer;
	end;
	
	TSize = record
		width: integer;
		height: integer;
	end;

	TSnakePart = TVector;
	
	TField = record
	  size: TSize;
	 
    style: record
      id: integer;
      borderColor: integer; 
      borderChar: char;
    end;
	end;
	
	TSnake = record
	  style: record
	    id: integer;
	    
	    headColor: integer;
      bodyColor: integer;
      
      headChar: char;
      bodyChar: char;   
	  end;
    
		direction: TVector;
		length: integer;
		parts: array of TSnakePart;
	end;
	
	TFood = record
    color: integer;
    satiation: integer;
    pos: TVector;
  end;
  
procedure ReadInteger(min,max: integer; var variable: integer; errorMsg: string);
begin
  {$i-}
  TextColor(stdInputColor);
  readln(variable);
  TextColor(stdPrintColor);
  
  if (IOResult <> 0) or (variable < min) 
  or (variable > max) then
  begin
    writeln(errorMsg);
    halt(1);
  end;
end;

procedure UpdateSnake(var snake: TSnake);
var
  i: integer;
begin  
  for i := 1 to snake.length do
  begin
    GotoXY(snake.parts[i].x, snake.parts[i].y);
    TextBackground(black);
    write(' ');  
  end;
  
  for i := snake.length downto 2 do
  begin
    GotoXY(snake.parts[i - 1].x, snake.parts[i - 1].y);
    snake.parts[i] := snake.parts[i - 1];
  end;
  
  GotoXY(1, 1);
  
  snake.parts[1].x := snake.parts[1].x + snake.direction.x;
  snake.parts[1].y := snake.parts[1].y + snake.direction.y;
  
  
  if snake.style.bodyChar = ' ' then
    TextBackground(snake.style.bodyColor)
  else
    TextColor(snake.style.bodyColor);
  
	for i := 2 to snake.length do
	begin
		GotoXY(snake.parts[i].x, snake.parts[i].y);
		write(snake.style.bodyChar) 
	end;
	
	if snake.style.headChar = ' ' then
    TextBackground(snake.style.headColor)
  else
    TextColor(snake.style.headColor);
	
	GotoXY(snake.parts[1].x, snake.parts[1].y);
	write(snake.style.headChar);
	
	GotoXY(1,1);
end;

procedure DrawField(field: TField);
var
	row, col: integer;
begin
	GotoXY(1, 1);
  TextColor(field.style.borderColor);
  TextBackground(Black);
	for col := 1 to field.size.width do
		write(field.style.borderChar);
		
	writeln;
	
	for row := 1 to field.size.height - 1 do
	begin
		write(field.style.borderChar);
    
    GotoXY(field.size.width, row);  
			
		writeln(field.style.borderChar);
	end;
	
	for col := 1 to field.size.width do
		write(field.style.borderChar);
	
	GotoXY(1,1);	
end;	

procedure SetFieldStyleSettings(var field: TField; 
  borderChar: char; borderColor: integer);

begin
  field.style.borderChar := borderChar;
  field.style.borderColor := borderColor;
end;

procedure InitField(var field: TField);
begin
  DrawField(field);
  case field.style.id of
    1: SetFieldStyleSettings(field, '#', Green);
    2: SetFieldStyleSettings(field, '/', Green);
    3: SetFieldStyleSettings(field, '|', Green);
  end;
end;

procedure SetSnakeStyleSettings(var snake: TSnake; 
headColor, bodyColor: integer;
headChar, bodyChar: char);
begin
  snake.style.headColor := headColor;
  snake.style.bodyColor := bodyColor;
  snake.style.headChar := headChar;
  snake.style.bodyChar := bodyChar;
end;

procedure InitSnake(var snake: TSnake; fieldSize: TSize);
begin
	SetLength(snake.parts, fieldSize.width * fieldSize.height);
	
	snake.length := 2;
	
	snake.parts[1].x := (fieldSize.width - snake.length) div 2;
	snake.parts[1].y := fieldSize.height div 2;
	
	snake.direction.x := 1;
	snake.direction.y := 0;	
	
	case snake.style.id of
    1: SetSnakeStyleSettings(snake, Red, Green, ' ', ' ');
    2: SetSnakeStyleSettings(snake, Green, Red, '0', '1');
    3: SetSnakeStyleSettings(snake, Yellow, Blue, ' ', ' ');
  end;
end;

procedure GetKey(var code: integer);
var
  c: char;
begin
  c := ReadKey;
  if c = #0 then
  begin
    c := ReadKey;
    code := -ord(c)
  end
  else
    code := ord(c); 
end;

procedure HandleKey(var snake: TSnake; var gameOver: boolean);
var
  code: integer;
begin
  GetKey(code);
  
  case code of
    27: 
      gameOver := true;
   -75: 
      begin 
        if snake.direction.x <> 1 then snake.direction.x := -1; 
        snake.direction.y := 0; 
      end;
   -72: 
      begin
        snake.direction.x := 0;
        if snake.direction.y <> 1 then snake.direction.y := -1;
      end;
   -77: 
      begin
        if snake.direction.x <> -1 then snake.direction.x := 1;   
        snake.direction.y := 0;
      end;
   -80: 
      begin
        snake.direction.x := 0;
        if snake.direction.y <> -1 then snake.direction.y := 1;
      end;
  end;

end;

function FindEmptyCell(snake: TSnake; fieldSize: TSize): TVector;
var
  i, y: integer;
  pos: TVector;
  finded: boolean;
begin
  pos.x := 3;
  pos.y := 3;
   
  for i := 1 to fieldSize.width * fieldSize.height do
  begin
    finded := true;
    pos.x := pos.x + 1;
    
    if pos.x = fieldSize.width then
    begin
      pos.y := pos.y + 1;
      pos.x := 2;
    end;

    for y := 1 to snake.length do
    begin
      if (snake.parts[y].x = pos.x) and (snake.parts[y].y = pos.y) then
      begin
        finded := false;
        break;
      end;
    end;
    
    if finded then
    begin
      FindEmptyCell := pos;
      break;
    end
  end;
   
end;

procedure UpdateFood(snake: TSnake; var food: TFood; fieldSize: TSize);
var
  i: integer;
begin
  food.satiation := Random(maxFoodSatiation) + 1;
  
  case food.satiation of
    1: food.color := Red;
    2: food.color := Blue;
    3: food.color := Yellow;
  end;
  
  food.pos.x := Random(fieldSize.width - 5) + 4;
  food.pos.y := Random(fieldSize.height - 5) + 4;
   
  for i := 1 to snake.length do
  begin
    if (food.pos.x = snake.parts[i].x) and (food.pos.y = snake.parts[i].y) then
      food.pos := FindEmptyCell(snake, fieldSize);
  end;
  
  GotoXY(food.pos.x, food.pos.y);
  TextBackground(food.color);
  write(' ');
  GotoXY(1,1);
  
end;

procedure ShowResultScreen(loose: boolean; snakeLength: integer);
var
  resultMsg, scoreMsg, scoreValueStr: string;
begin
  delay(1500);
  write(#27'[0m');
  if loose then
    TextColor(LightRed or blink)
  else 
    TextColor(LightGreen or blink);
    
  clrscr;
  if loose then
    resultMsg := 'GAME OVER!!!'
  else
    resultMsg := 'You win !!!';
  
  // 12 - length of 'Game OVer!!!'
  GotoXY((ScreenWidth - length(resultMsg)) div 2, ScreenHeight div 2);
  Writeln(resultMsg);
  
  TextColor(LightCyan or blink);
  
  Str(snakeLength - 1, ScoreValueStr);
  scoreMsg := 'Score: ' + ScoreValueStr;
  
  // 12 - length of 'Score'
  GotoXY((ScreenWidth - length(scoreMsg)) div 2, (ScreenHeight div 2) + 1);
  writeln(scoreMsg);
  delay(4000);
end;

procedure HandleCollision(var snake: TSnake; fieldSize: TSize; 
var gameOver: boolean; var food: TFood);
var
  snakeHead: TSnakePart;
  i: integer;
begin
  snakeHead := snake.parts[1];
    
  // Snake part
  for i := 2 to snake.length do
    if (snakeHead.x = snake.parts[i].x) and 
    (snakeHead.y = snake.parts[i].y) then
    begin
      ShowResultScreen(true, snake.length);
      gameOver := true;
      exit;
    end;
    
  // Border
  if snakeHead.x = fieldSize.width then
    snake.parts[1].x := 2
  else if snakeHead.x = 1 then
    snake.parts[1].x := fieldSize.width - 1 
  else if snakeHead.y = fieldSize.height then
    snake.parts[1].y := 2
  else if snakeHead.y = 1 then
    snake.parts[1].y := fieldSize.height - 1;
  // Food
  if (snakeHead.x = food.pos.x) and (snakeHead.y = food.pos.y) then
  begin
      
    snake.length := snake.length + food.satiation;
    
    if snake.length >= ((fieldSize.width * fieldSize.height) div 2) then
    begin
      ShowResultScreen(false, snake.length);
      gameOver := true;
    end;
    
    UpdateFood(snake, food, fieldSize);
  end;
end;

procedure ShowGuide();
begin
  clrscr;

  TextColor(stdPrintColor);
  write('If you want to ');
  TextColor(LightRed);
  write('Exit');
  TextColor(stdPrintColor);
  write(', press ');
  TextColor(LightRed);
  writeln('ESCAPE');
  TextColor(stdPrintColor);
  
  writeln;
  TextBackground(Red);
  write(' ');
  TextColor(LightRed);
  TextBackground(Black);
  writeln(' - Gives you 1 point');
  
  TextBackground(Blue);
  write(' ');
  TextColor(Blue);
  TextBackground(Black);
  writeln(' - Gives you 2 point');
  
  TextBackground(Yellow);
  write(' ');
  TextColor(Yellow);
  TextBackground(Black);
  writeln(' - Gives you 3 point');
  
  writeln;
  
  TextColor(LightMagenta);
  writeln('Enjoy it!');
  writeln;
  
  TextColor(stdPrintColor);
  delay(1500);
  write('Press ');
  TextColor(LightRed);
  write('Enter');
  TextColor(stdPrintColor);
  writeln(' to start...');
  readln;
end;

procedure SetSettings(var snake: TSnake; var field: TField);
var
  c: char;
  styleId: integer;
begin
  repeat
    TextColor(stdPrintColor);
    
    write('Do you want to start with standard settings? (y/n): ');
    
    TextColor(stdInputColor);
    readln(c);
  until (c = 'n') or (c = 'y');
  
  if c = 'n' then
  begin
    
    TextColor(stdPrintColor);
    write('Field width[',minFieldWidth,' - ', ScreenWidth - 5,']: ');
    ReadInteger(minFieldWidth, ScreenWidth - 5, field.size.width, 
    'You entered an incorrect field width');
    
    TextColor(stdPrintColor);
    write('Field height[',minFieldHeight,' - ', ScreenHeight - 2,']: ');
    ReadInteger(minFieldHeight, ScreenHeight - 2, field.size.height, 
    'You entered an incorrect field height');

     
    TextColor(stdPrintColor);
    write('Select style[',1,' - ', maxStyleId,']: ');
    ReadInteger(1, maxStyleId, styleId, 
    'You entered style that doesn''t exist' );
     
  end
  else
  begin
    styleId := 1;
    field.size.width := 20;
    field.size.height := 14;
  end;
  
  snake.style.id := styleId;
  field.style.id := styleId;
end;

var
	snake: TSnake;
	food: TFood;	
	field: TField;
	gameOver: boolean;
	
begin
  randomize;
  gameOver := false;
  clrscr;
  
  SetSettings(snake, field);
  ShowGuide();
  
  clrscr;
  
  InitSnake(snake, field.size);
  InitField(field);
  
  UpdateFood(snake, food, field.size);

	while not gameOver do
	begin
    delay(delayDuration);
	  	  
    if KeyPressed then
      HandleKey(snake, gameOver);
    
    UpdateSnake(snake);
    HandleCollision(snake, field.size, gameOver, food);
      DrawField(field);
  
	end;
	
	
	write(#27'[0m');
	clrscr;
end.
