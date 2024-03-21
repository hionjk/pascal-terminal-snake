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
	
	borderChar = '#';
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
	
	TSnake = record
	  color: integer;
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

procedure SetSettings(var fieldSize: TSize; var snake: TSnake);
begin
  TextColor(stdPrintColor);
  write('Field width[',minFieldWidth,' - ', ScreenWidth - 5,']: ');
  ReadInteger(minFieldWidth, ScreenWidth - 5, fieldSize.width, 
  'You entered an incorrect field width');
  
  TextColor(stdPrintColor);
  write('Field height[',minFieldHeight,' - ', ScreenHeight - 2,']: ');
  ReadInteger(minFieldHeight, ScreenHeight - 2, fieldSize.height, 
  'You entered an incorrect field height');
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
    write(' ');
  
    snake.parts[i] := snake.parts[i - 1];
  end;
  
  GotoXY(1, 1);
  
  snake.parts[1].x := snake.parts[1].x + snake.direction.x;
  snake.parts[1].y := snake.parts[1].y + snake.direction.y;
  
  TextBackground(snake.color);
	for i := 2 to snake.length do
	begin
		GotoXY(snake.parts[i].x, snake.parts[i].y);
		write(' ') 
	end;
	
	TextBackground(Red);
	
	GotoXY(snake.parts[1].x, snake.parts[1].y);
	write(' ');
	
	GotoXY(1,1);
end;

procedure DrawBorder(size: TSize);
var
	row, col: integer;
begin
	GotoXY(1, 1);
  TextColor(LightGreen);
  TextBackground(Black);
	for col := 1 to size.width do
		write(borderChar);
		
	writeln;
	
	for row := 1 to size.height - 1 do
	begin
		write(borderChar);
    
    GotoXY(size.width, row);  
			
		writeln(borderChar);
	end;
	
	for col := 1 to size.width do
		write(borderChar);
	
	GotoXY(1,1);	
end;	

procedure InitSnake(var snake: TSnake; fieldSize: TSize);
begin
	SetLength(snake.parts, fieldSize.width * fieldSize.height);

	snake.parts[1].x := 2;
	snake.parts[1].y := 2;
	
	snake.length := 2;
	snake.color := LightGreen;
	
	snake.direction.x := 1;
	snake.direction.y := 0;	
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

procedure HandleCollision(var snake: TSnake; var gameOver: boolean; 
var food: TFood; fieldSize: TSize);
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
  begin
    snake.parts[1].x := 2;
    DrawBorder(fieldSize);
  end
  else if snakeHead.x = 1 then
  begin
    snake.parts[1].x := fieldSize.width - 1;  
    DrawBorder(fieldSize);  
  end
  else if snakeHead.y = fieldSize.height then
  begin
    snake.parts[1].y := 2;
    DrawBorder(fieldSize);
  end
  else if snakeHead.y = 1 then
  begin
    snake.parts[1].y := fieldSize.height - 1;
    DrawBorder(fieldSize);
  end;
  // Food
  if (snakeHead.x = food.pos.x) and (snakeHead.y = food.pos.y) then
  begin
      
    snake.length := snake.length + food.satiation;
    DrawBorder(fieldSize);
    
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
end;

procedure ShowWelcomeScreen(var fieldSize: TSize; var snake: TSnake);
var
  c: char;
begin
  
  repeat
    TextColor(stdPrintColor);
    
    write('Do you want to start with standard field size (',
    fieldSize.width,'x',fieldSize.height,')? (y/n): ');
    
    TextColor(stdInputColor);
    readln(c);
  until (c = 'n') or (c = 'y');
  
  if c = 'n' then
    SetSettings(fieldSize, snake); 
  
  writeln();
  clrscr;
  GotoXY(1,1);
  
  ShowGuide();
  
  TextColor(LightMagenta);
  write('Enjoy it!');
  writeln;
  writeln;
  TextColor(stdPrintColor);
  delay(1500);
  write('Press ');
  TextColor(LightRed);
  write('Enter');
  TextColor(stdPrintColor);
  writeln(' to start...');
  readln;
  
  clrscr;
end;

var
	snake: TSnake;
	food: TFood;	
	fieldSize: TSize;
	gameOver: boolean;
	c: char;
	bgColor: integer;
	
begin

  fieldSize.width := 30;
  fieldSize.height := 18;
  bgColor := Black;
  
  randomize;
  gameOver := false;
  clrscr;
  
  InitSnake(snake, fieldSize);

  ShowWelcomeScreen(fieldSize, snake);
  
  clrscr;
  
  UpdateFood(snake, food, fieldSize);
  
  DrawBorder(fieldSize);
  
	while not gameOver do
	begin
    delay(delayDuration);
	  	  
    if KeyPressed then
      HandleKey(snake, gameOver);
    
    UpdateSnake(snake);
    HandleCollision(snake, gameOver, food, fieldSize);
    
	end;
	
	write(#27'[0m');
	clrscr;
end.
