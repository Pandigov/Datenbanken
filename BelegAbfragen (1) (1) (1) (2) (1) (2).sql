--2.1 a)
SELECT KunName
FROM Kunde 
WHERE KunOrt = 'Radebeul'


--2.1 b)
SELECT * 
FROM Kunde 
WHERE KunOrt NOT LIKE 'Chemnitz'


--2.1 c)
SELECT EtBezeichnung
FROM Ersatzteil 
WHERE EtBezeichnung LIKE 'S%'


--2.1 c)
SELECT AufNr 
FROM Auftrag 
WHERE Dauer BETWEEN '2' AND '3' 
	  OR Anfahrt > 80


--2.1 d)
SELECT MitName, 
	   MitVorname, 
       MitJob,
	   MitEinsatzort
FROM Mitarbeiter 
WHERE MitEinsatzort = 'Radebeul' 
	  AND (MitJob = 'Azubi' 
	  OR MitJob = 'Monteur')
ORDER BY MitName


--2.1 e)
SELECT AufNr
FROM Auftrag 
WHERE Dauer IS NULL


--2.1 f)
SELECT AufNr, 
       format(Anfahrt*2.5, 'c', 'de-DE') AS Anfahrtskosten
FROM Auftrag


--2.1 g)
SELECT EtPreis*EtAnzLager AS Erlös
FROM Ersatzteil


--2.2 a)
SELECT MitName, 
	   Mitvorname, 
	   MitGebDat, 
	   DATEDIFF(YEAR, MitGebDat, GETDATE()) - 
	   CASE WHEN (DATEADD(YEAR, DATEDIFF(YEAR, MitGebDat, GETDATE()), MitGebDat)) > GETDATE()
			THEN 1
			ELSE 0
	   END AS [Alter]
FROM Mitarbeiter


--2.2 b)
SELECT AVG(DATEDIFF(DAY, AufDat, ErlDat)) 
FROM Auftrag 
WHERE MONTH(AufDat) = MONTH(GETDATE())


--2.2 c)
SELECT AufNr, 
	   ISNULL(Dauer, 0) AS Dauer
FROM Auftrag


--2.3 a)
SELECT COUNT(KunNr) 
FROM Kunde


--2.3 b)
SELECT KunOrt, 
       COUNT(KunNr) AS [Kunden je Ort]
FROM Kunde 
GROUP BY KunOrt


--2.3 c)
SELECT MitID,
      Cast(AVG(Dauer) AS decimal(2,1)) AS [Durchschnittliche Dauer]
FROM Auftrag 
GROUP BY MitID


--2.3 d)
SELECT MitID, 
	   Cast(AVG(Dauer) AS decimal(2,1)) AS Durchschnitt,
	   MIN(Dauer) AS Minimum, 
	   MAX(dauer) AS Maximum 
FROM Auftrag 
GROUP BY MitID


--2.3 e)
SELECT MitID, 
	   Cast(AVG(Dauer) AS decimal(2,1)) AS Durchschnitt,
       MIN(Dauer) AS Minimum, 
       MIN(dauer) AS Maximum, 
	   ErlDat, 
       COUNT(AufNr) AS [Aufträge pro Tag]
FROM Auftrag 
GROUP BY MitID, ErlDat


--2.3 f)
SELECT DATEADD(DAY, 1, AufDat) as ErlDat 
FROM Auftrag 
WHERE Dauer IS NULL 
	  AND ErlDat IS NOT NULL


--2.4 a)
SELECT MitID,
	   Cast(AVG(Dauer) AS decimal(2,1)) AS Durchschnitt,
	   DATENAME(WEEKDAY, ErlDat) AS Wochentag
FROM Auftrag
GROUP BY MitID, 
		 DATENAME(WEEKDAY, ErlDat), 
		 DATEPART(WEEKDAY,ErlDat)
ORDER BY DATEPART(WEEKDAY,ErlDat)

--2.5 a)
SELECT AufNr, 
	   EtBezeichnung, 
	   Anzahl, 
	   EtPreis, 
	   Anzahl*EtPreis as Erlös
FROM Montage m
JOIN Ersatzteil e 
ON m.EtID= e.EtID
ORDER BY AufNr

--2.5 b)
SELECT m.MitID,
	   MitStundensatz*Dauer AS Lohnkosten
FROM Mitarbeiter m
JOIN Auftrag a 
ON m.MitID=a.MitID
GROUP BY m.MitID, MitStundensatz*Dauer

--2.5 c)
SELECT KunName,
	   KunOrt,
	   Anfahrt
FROM Kunde k
JOIN Auftrag a
ON k.KunNr=a.KunNr
WHERE Anfahrt>50

--2.5 d)
SELECT KunNr
FROM Montage m
JOIN Auftrag a
ON m.AufNr=a.AufNr
JOIN Ersatzteil e
ON e.EtID=m.EtID
WHERE EtBezeichnung = 'Temperaturfühler'

--2.5 e)
SELECT a.AufNr,
	   Dauer*m.MitStundensatz AS Lohnkosten,
	   Anzahl*e.EtPreis AS Materialkosten,
	   (Anfahrt*2.5) AS Fahrtkosten
FROM Auftrag a
JOIN Mitarbeiter m 
ON a.MitID = m.MitID
JOIN Montage mo
ON mo.AufNr=a.AufNr
JOIN Ersatzteil e 
ON e.EtID=mo.EtID
GROUP BY a.AufNr,Dauer*m.MitStundensatz,
	     Anzahl*e.EtPreis,
	    (Anfahrt*2.5) 

--2.5 f)
SELECT a.AufNr,
	   MitName,
	   MitVorname
FROM Auftrag a
JOIN Montage mo ON mo.AufNr=a.AufNr
JOIN Mitarbeiter m ON m.MitID=a.MitID
WHERE MONTH(AufDat)=MONTH(GETDATE())

--2.5 g)
SELECT EtBezeichnung,
       count(e.EtID) AS [Anzahl Ersatzteil]
FROM Auftrag a
JOIN Montage mo 
On mo.AufNr=a.AufNr
JOIN Ersatzteil e 
ON mo.EtID=e.EtID
WHERE MONTH(AufDat)=(MONTH(GETDATE())-1)
GROUP BY e.EtID, EtBezeichnung


--2.6 a)
SELECT MitName,
	   MitVorname,
	   MitID
FROM Mitarbeiter 
WHERE MitID NOT IN (SELECT MitID
				    FROM Auftrag 
				    WHERE MitID IS NOT NULL
					AND DATEDIFF(MONTH, AufDat, GETDATE())=0)


--2.6 a)-Zusatz
SELECT MitID
FROM Mitarbeiter
EXCEPT
SELECT MitID
FROM Auftrag 
WHERE DATEDIFF(MONTH, AufDat, GETDATE())=0

					
--2.6 b)
SELECT a.AufNr,
	   (Dauer * m.MitStundensatz) AS Lohnkosten,
       (Anfahrt * 2.5) AS Fahrtkosten
FROM Auftrag a
JOIN Mitarbeiter m 
ON a.MitID = m.MitID
JOIN Montage mo
ON mo.AufNr = a.AufNr
WHERE a.AufNr NOT IN (SELECT AufNr
					  FROM Montage)


--2.6 c)
SELECT AufNr
FROM Auftrag
WHERE AufDat = (SELECT MIN(AufDat)
			    FROM Auftrag
			    WHERE AufDat IS NOT NULL 
			    AND Dauer IS NULL)


--2.6 d)
SELECT DISTINCT KunNr
FROM Auftrag
WHERE KunNr NOT IN (SELECT KunNr
				    FROM Auftrag
				    WHERE DATEPART(MONTH, AufDat) NOT LIKE 3)
					

--2.6 e) 1)
SELECT m.MitID,
	   AufNr,
	   Dauer
FROM Mitarbeiter m
JOIN Auftrag a
ON m.MitID=a.MitID
WHERE Dauer = (SELECT MAX(Dauer)
               FROM Auftrag a
	           WHERE m.MitID = a.MitID)


--2.6 e) 2)
SELECT AufNr,
	   a.MitID,
	   Dauer
FROM (SELECT MitID, 
			 MAX(Dauer) AS Maximum
	  FROM Auftrag
	  GROUP BY MitID) AS UA
JOIN Auftrag a
ON UA.MitID = a.MitID
WHERE Maximum = Dauer
			  

--2.7 a)
SELECT MitID,
       MONTH(AufDat) AS Monat,
	   SUM(Anfahrt) AS Gesamtstrecke
FROM Auftrag
WHERE MONTH(AufDat) = 4
GROUP BY MitID, 
	     MONTH(AufDat)
HAVING SUM(Anfahrt) > 500


--2.7 b)
SELECT m.EtID,
	   e.EtAnzLager,
	   SUM(Anzahl) as Gesamtverbrauch
FROM Montage m
JOIN Ersatzteil e
ON e.EtID = m.EtID
GROUP BY m.EtID, EtAnzLager
HAVING SUM(Anzahl) < EtAnzLager


--2.8 a)
INSERT INTO Kunde 
VALUES (1501, 'Munkelt', 'Dresden', '01344', 'Teststraße 29')

INSERT INTO Auftrag 
VALUES(5811, 104, 1501, '2022-05-30', '2022-06-03', 1.5, 30,'Beschreibung')


--2.8 b)
UPDATE Mitarbeiter 
SET MitJob = 'Monteur',
	MitStundensatz = (SELECT MIN(MitStundensatz)
					  FROM Mitarbeiter
					  WHERE MitJob = 'Monteur')
WHERE MitJob = 'Azubi'


--2.8 c)
DELETE FROM Montage
WHERE EtID IN (SELECT EtID
		       FROM Ersatzteil
			   WHERE EtHersteller = 'Mosch')
DELETE FROM Ersatzteil
WHERE EtHersteller = 'Mosch'




--2.8 d)
DELETE FROM Montage
WHERE AufNr IN (SELECT AufNr
				FROM Auftrag
				WHERE KunNr NOT IN (SELECT KunNr
									FROM Auftrag
									WHERE DATEPART(MONTH, AufDat) NOT LIKE 3))
DELETE FROM Auftrag
WHERE AufNr IN (SELECT AufNr
				FROM Auftrag
				WHERE KunNr NOT IN (SELECT KunNr
									FROM Auftrag
									WHERE DATEPART(MONTH, AufDat) NOT LIKE 3))
DELETE FROM Kunde
WHERE KunNr IN (SELECT KunNr
				FROM Auftrag
				WHERE KunNr NOT IN (SELECT KunNr
									FROM Auftrag
									WHERE DATEPART(MONTH, AufDat) NOT LIKE 3))



--2.9 Differenz
SELECT KunOrt
FROM Kunde
EXCEPT
SELECT MitEinsatzort
FROM Mitarbeiter

--2.9 Durchschnitt
SELECT KunOrt
FROM Kunde
INTERSECT
SELECT MitEinsatzort
FROM Mitarbeiter

--2.9 Vereinigung
SELECT KunOrt
FROM Kunde
UNION
SELECT MitEinsatzort
FROM Mitarbeiter


--2.10
GO
CREATE VIEW Auftragswert AS
SELECT a.AufNr,	
	   ErlDat,
	   KunOrt,
	   ISNULL((Anfahrt*2.5),0) AS Anfahrtskosten,
	   ISNULL((Dauer*m.MitStundensatz),0) AS Lohnkosten 
FROM Auftrag a
JOIN Kunde k
ON a.KunNr=k.KunNr
JOIN Montage mo
ON a.AufNr=mo.AufNr
JOIN Mitarbeiter m
ON m.MitID=a.MitID
WHERE ErlDat IS NOT NULL
GO

SELECT AufNr,
	   CAST ((Anfahrtskosten + Lohnkosten) AS DECIMAL(5,2)) AS Gesamtkosten
FROM Auftragswert


--2.11
SELECT AufNr,
	  CASE WHEN (Anfahrtskosten) > 30
	  THEN Anfahrtskosten
	  ELSE 30 
	  END AS Anfahrtspreis
FROM Auftragswert


--3.1
GO
CREATE PROCEDURE AuftragbeiKunde(@MitID int, @KunNr int)
AS
	SELECT COUNT(AufNr) AS [Anzahl Auftraege]
	FROM Auftrag a
	WHERE @MitID = a.MitID
		  AND @KunNr = a.KunNr
RETURN
GO

EXEC AuftragbeiKunde 110, 1409


--3.2
GO
CREATE PROCEDURE Oefterals (@Anzahl int)
AS
	SELECT EtID,
		   SUM(Anzahl) AS Gesamt
	FROM Montage
	GROUP BY EtID, 
	         Anzahl
	HAVING @Anzahl < SUM(Anzahl)
RETURN
GO

EXEC Oefterals 20

DROP PROCEDURE Oefterals


--3.3

SELECT * INTO AuftragKopie2 FROM trommelhelden..quelleAuftrag



GO
CREATE PROCEDURE UpdateAuftrag (@AnzahlTage int)
AS
	DECLARE @tag date = (SELECT MIN(AufDat)
						 FROM Auftrag
			             WHERE AufDat IS NOT NULL 
			             AND Dauer IS NULL)
	DECLARE	@enddate date = DATEADD(DAY, @AnzahlTage, @tag)

	WHILE @tag <= @enddate 
	BEGIN	
		UPDATE AuftragKopie6
		SET Dauer = ((CONVERT(int,RAND()*9)+1)*0.5),
			Anfahrt = (CONVERT(int,RAND()*95)+5),
			Beschreibung = 'Die Werte wurden automatisch generiert'
		WHERE AufNr IN (SELECT AufNr
						FROM AuftragKopie6
						WHERE AufDat = @tag
						AND Dauer IS NULL 
					    AND Anfahrt IS NULL 
			            AND Beschreibung IS NULL)

		PRINT CONVERT(VARCHAR, DATEDIFF(DAY, @tag, @enddate))  + ' tage verbleibend'
		SET @tag = DATEADD(DAY, 1, @tag)
		
	END
RETURN 
GO

DROP Table AuftragKopie5



EXEC UpdateAuftrag 2



--3.4
GO
CREATE PROCEDURE Updateauftragcursor (@AnzahlTage int)
AS
	DECLARE @tag date = (SELECT MIN(AufDat)
						 FROM Auftrag
			             WHERE AufDat IS NOT NULL 
			             AND Dauer IS NULL)

	DECLARE	@enddate date = DATEADD(DAY, @AnzahlTage, @tag)

	DECLARE UpdateAuftrag_cursor CURSOR 
	FOR
		SELECT Dauer, Anfahrt, Beschreibung
		FROM AuftragKopie2
		WHERE AufDat = (SELECT MIN(AufDat)
						 FROM AuftragKopie2
						 WHERE AufDat IS NOT NULL 
						 AND Dauer IS NULL)
			  AND Dauer IS NULL 
			  AND Anfahrt IS NULL 
			  AND Beschreibung IS NULL
	FOR UPDATE OF Dauer, Anfahrt, Beschreibung

	OPEN UpdateAuftrag_cursor
	FETCH NEXT FROM UpdateAuftrag_cursor

	WHILE(SELECT MIN(AufDat)FROM AuftragKopie2 WHERE AufDat IS NOT NULL 
						 AND Dauer IS NULL) <= @enddate
	BEGIN

		WHILE @@FETCH_STATUS = 0
			BEGIN 
				UPDATE AuftragKopie2
				SET Dauer = ((CONVERT(int,RAND()*9)+1)*0.5),
					Anfahrt = (CONVERT(int,RAND()*95)+5),
					Beschreibung = 'Die Werte wurden automatisch generiert' 
					WHERE CURRENT OF UpdateAuftrag_cursor
	
	    
				FETCH NEXT FROM UpdateAuftrag_cursor
		
			END
	
	END	
CLOSE UpdateAuftrag_cursor
DEALLOCATE UpdateAuftrag_cursor
RETURN
GO


EXEC Updateauftragcursor2 3

SELECT * FROM AuftragKopie2

DROP PROCEDURE Updateauftragcursor2


--3.4
GO
CREATE PROCEDURE Updateauftragcursor2 (@AnzahlTage int)
AS
	DECLARE @tag date = (SELECT MIN(AufDat)
						 FROM Auftrag
			             WHERE AufDat IS NOT NULL 
			             AND Dauer IS NULL)

	DECLARE	@enddate date = DATEADD(DAY, @AnzahlTage, @tag)

	DECLARE @aufnr2 int 

	DECLARE UpdateAuftrag_cursor CURSOR 
	FOR
		SELECT Aufnr
		FROM AuftragKopie2
		WHERE AufDat = (SELECT MIN(AufDat)
						 FROM AuftragKopie2
						 WHERE AufDat IS NOT NULL 
						 AND Dauer IS NULL)
			  AND Dauer IS NULL 
			  AND Anfahrt IS NULL 
			  AND Beschreibung IS NULL
	FOR UPDATE OF Dauer, Anfahrt, Beschreibung

	

	WHILE(@AnzahlTage>0)
  BEGIN
	 OPEN UpdateAuftrag_cursor
	 FETCH UpdateAuftrag_cursor INTO @aufnr2
		WHILE @@FETCH_STATUS = 0
			BEGIN 
				UPDATE AuftragKopie2
				SET Dauer = ((CONVERT(int,RAND()*9)+1)*0.5),
					Anfahrt = (CONVERT(int,RAND()*95)+5),
					Beschreibung = 'Die Werte wurden automatisch generiert' 
					WHERE Aufnr=@aufnr2
	
	    
				FETCH UpdateAuftrag_cursor INTO @aufnr2
		
			END
			SET @AnzahlTage=@AnzahlTage-1
	CLOSE UpdateAuftrag_cursor

	END	
DEALLOCATE UpdateAuftrag_cursor
RETURN
GO