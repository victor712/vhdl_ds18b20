--Date:       2014.6.4 
LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.std_logic_unsigned.all; 
USE ieee.std_logic_arith.all; 
 
 
ENTITY DS18B20 IS  PORT 
(
	CLK:IN STD_LOGIC;--12MHz 
	DQ:INOUT std_logic;--IO to DS18B20 
	TEMP_OUT:OUT std_logic_vector(7 downto 0)--sign[7]+INTEGER_PART[6..0]  
--  TEMP_OUT0:OUT std_logic_vector(7 downto 0);--FRACTION_PART[3..0]+INTEGER_PART[7..4]
--  TEMP_OUT1:OUT std_logic_vector(7 downto 0)--INTEGER_PART[3..0]+sign_temp[2..0]+sign
); 
END DS18B20; 

ARCHITECTURE block_name_architecture OF DS18B20 IS 
	SIGNAL count_int 		: std_logic_vector(7 downto 0); 
	SIGNAL fen 				: std_logic_vector(5 downto 0); 
	SIGNAL num         		: std_logic_vector(13 downto 0); 
	SIGNAL T1        		: std_logic_vector(7 downto 0);--
	SIGNAL T0       		: std_logic_vector(7 downto 0);-- 
	SIGNAL SIGN0    	    : std_logic;--
BEGIN 
	PROCESS(CLK)--7 Digital Counter 
		BEGIN 
			--WAIT UNTIL rising_edge(CLK); 
			IF rising_edge(CLK) THEN 
				fen<=fen+1; 
				IF (fen>=20 OR fen<0) THEN  
					count_int <= count_int+1; 
					fen<="000000"; 
				END IF; 
				--D<=count_int; 
				IF (num>=11200 OR num<=0) THEN--11000 
					num<="00000000000000"; 
				END IF; 
				IF (count_int>=70 OR count_int<0) THEN 
					count_int<="00000000"; 
					num<=num+1; 
					--S<=num; 
				END IF; 
				IF (num>=0 AND num<=6) THEN--Reset 
					DQ<='0'; 
				END IF; 
				IF (num>=7 AND num<=13) THEN--Present 
					DQ<='Z'; 
				END IF; 
					--Start OF SKIP 1100 1100    Start at 14-------(CC) 
				IF (num=16 OR num=17 OR num=20 OR num=21) THEN--SKip Write 1 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
				END IF; 
				IF (num=14 OR num=15 OR num=18 OR num=19) THEN--SKip Write 0 
					IF (count_int>=0 AND count_int<=60) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=61 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
				END IF; 
           --Stop OF SKIP 
           --Start OF Convert--0100 0100 Start at 22-------(44) 
           --                    22,23,25,26,27,29  
				IF (num=22 OR num=23 OR num=25 OR num=26 OR num=27 OR num=29) THEN--Convert Write 0 
					IF (count_int>=0 AND count_int<=60) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=61 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
				END IF; 
				IF (num=24 OR num=28) THEN--Convert Write 1 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
				END IF;    
   --End OF Convert 
				IF (num>=11100 AND num<=11106) THEN--Reset 
					DQ<='0'; 
				END IF; 
				IF (num>=11108 AND num<=11113) THEN--Present 
					DQ<='Z'; 
				END IF; 
   --Start OF SKIP 1100 1100    Start at 114 -------(CC)
				IF (num=11116 OR num=11117 OR num=11120 OR num=11121) THEN--SKip Write 1 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
				END IF;
				IF (num=11114 OR num=11115 OR num=11118 OR num=11119) THEN--SKip Write 0 
					IF (count_int>=0 AND count_int<=60) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=61 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
				END IF; 
           --Stop OF SKIP 
   --Start OF READ SCRATCHPAD--1011 1110 Start at 22 -------(BE)
           --                    22,28  
				IF (num=11122 OR num=11128) THEN--Convert Write 0 
					IF (count_int>=0 AND count_int<=60) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=61 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
				END IF; 
				IF (num=11123 OR num=11124 OR num=11125 OR num=11126 OR num=11127 OR num=11129) THEN--Convert Write 1 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
				END IF;    
   --End OF READ SCRATCHPAD 
   --Start OF Read Temperature 
				IF (num=11131) THEN  --1 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0';
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T0(0)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
							T0(0)<='1'; 
						END IF; 
					END IF; 
				END IF; 
				IF (num=11132) THEN  --2 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T0(1)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
							T0(1)<='1'; 
						END IF; 
					END IF; 
				END IF; 
				IF (num=11133) THEN  --3 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T0(2)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
							T0(2)<='1'; 
						END IF; 
					END IF; 
				END IF; 
				IF (num=11134) THEN  --4 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T0(3)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
							T0(3)<='1'; 
						END IF; 
					END IF; 
				END IF; 
				IF (num=11135) THEN  --5 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T0(4)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
							T0(4)<='1'; 
						END IF; 
					END IF; 
				END IF; 
				IF (num=11136) THEN  --6 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T0(5)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
							T0(5)<='1'; 
						END IF; 
					END IF; 
				END IF; 
				IF (num=11137) THEN  --7 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T0(6)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
						T0(6)<='1'; 
						END IF; 
					END IF; 
				END IF; 
				IF (num=11138) THEN  --8 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T0(7)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
							T0(7)<='1'; 
						END IF; 
					END IF; 
				END IF; 
				IF (num=11139) THEN  --9 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T1(0)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
							T1(0)<='1'; 
						END IF; 
					END IF; 
				END IF; 
				IF (num=11140) THEN  --10 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T1(1)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
							T1(1)<='1'; 
						END IF; 
					END IF; 
				END IF;
				IF (num=11141) THEN  --11 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T1(2)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
							T1(2)<='1'; 
						END IF;
					END IF; 
				END IF; 
				IF (num=11142) THEN  --12 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T1(3)<='0'; 
						END IF; 
						IF (DQ='1') THEN 
							T1(3)<='1'; 
						END IF; 
					END IF; 
				END IF; 
				IF (num=11143) THEN  --13 
					IF (count_int>=0 AND count_int<=6) THEN 
						DQ<='0'; 
					END IF; 
					IF (count_int>=7 AND count_int<=70) THEN 
						DQ<='Z'; 
					END IF;  
					IF (count_int=12) THEN 
						IF (DQ='0') THEN 
							T1(4)<='0';
							T1(5)<='0';
							T1(6)<='0';
							T1(7)<='0';				 
						END IF; 
						IF (DQ='1') THEN 
							T1(4)<='1';
							T1(5)<='1';
							T1(6)<='1';
							T1(7)<='1';
						END IF; 
					END IF; 
				END IF; 
	--End OF Read Temperature 
				IF (num>=11145 OR num<=11146) THEN 
					TEMP_OUT(7)<=T1(7);		--Sign Part	
					TEMP_OUT(6 downto 4)<=T1(2 downto 0);		--Integer Part
					TEMP_OUT(3 downto 0)<=T0(7 downto 4);		--Integer Part
				END IF; 
		END IF; 
	END PROCESS; 
END block_name_architecture; 
 
