# SQI
fNIR Quality Control - SQI Signal Quality Index

Signal quality is the reference standard for excluding channels and bad segments in signal processing. For this reason, a paper has developed, in collaboration with Artinis, an algorithm called SignalQualityIndex (SQI), which evaluates the signal quality using a 5-point scale ranging from 1 (for very low signal quality) to 5 (for very high signal quality). The algorithm calculates the SQI index for each measurement channel within a segmented time window, and details of the algorithm's calculations can be found in the paper at the relevant link.

I have here packaged the SQI algorithm provided in the paper into a matlab tool that can read the file in oxysoft format directly and plot and save the data.

The devices mentioned in the paper include OctaMon, Brite 23, Brite 24, and OxyMon.

RELATED:

1.https://www.artinis.com/blogpost-all/2023/assessing-nirs-signal-quality-implementation-of-the-signal-quality-index-sqi
2.https://opg.optica.org/boe/fulltext.cfm?uri=boe-11-11-6732&id=441993
