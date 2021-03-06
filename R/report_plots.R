#' Make plot of ORFik QCreport
#'
#' From post-alignment QC relative to annotation, make a plot for all samples.
#' Will contain among others read lengths, reads overlapping leaders,
#' cds, trailers, mRNA / rRNA etc.
#' @param stats path to ORFik QC stats .csv file, or the experiment object.
#' @param output.dir NULL or character path, default: NULL, plot not saved to disc.
#' If defined saves plot to that directory with the name "/STATS_plot.pdf".
#' @param plot.ext character, default: ".pdf". Alternatives: ".png" or ".jpg".
#' @return ggplot object of the the statistics data
#' @importFrom data.table melt
#' @importFrom gridExtra grid.arrange
#' @export
#' @examples
#' df <- ORFik.template.experiment()[3,]
#' ## First make QC report
#' # QCreport(df)
#' ## Now you can get plot
#' # QCstats.plot(df)
QCstats.plot <- function(stats, output.dir = NULL, plot.ext = ".pdf") {
  if (is(stats, "experiment")) {
    path <- file.path(dirname(stats$filepath[1]), "QC_STATS/")
    stats <- QCstats(stats)
    if (is.null(stats))
      stop("No QC report made for experiment, run ORFik QCreport")
  } else {
    path <- stats
    stats <- fread(stats)
  }
  if (colnames(stats)[1] == "V1") colnames(stats)[1] <- "sample_id"

  temp_theme <-  theme(legend.text=element_text(size=8),
                       legend.key.size = unit(0.3, "cm"),
                       plot.title = element_text(size=11),
                       strip.text.x = element_blank(),
                       panel.grid.minor = element_blank())

  stats$sample_id <-  factor(stats$Sample,
                             labels = as.character(seq(length(stats$Sample))),
                             levels = stats$Sample)
  stats$Sample <-  factor(stats$Sample, levels = stats$Sample)
  colnames(stats) <- gsub("percentage", "%", colnames(stats))
  # Update all values to numeric
  stats[,(seq.int(ncol(stats))[-c(1,2)]):= lapply(.SD, as.numeric),
        .SDcols = seq.int(ncol(stats))[-c(1,2)]]
  dt_plot <- melt(stats, id.vars = c("Sample", "sample_id"))

  step_counts <- c("mRNA", "rRNA")
  stat_regions <- colnames(stats)[c(which(colnames(stats) %in% step_counts))]
  dt_STAT <- dt_plot[(variable %in% stat_regions),]
  dt_STAT_normalized <- copy(dt_STAT)
  dt_STAT_normalized[, sample_total := sum(value), by = .(sample_id)]
  dt_STAT_normalized[, percentage := (value / sample_total)*100]

  gg_STAT <- ggplot(data = dt_STAT_normalized, aes(x = sample_id, y = percentage)) +
    geom_bar(aes(fill = variable), stat="identity", position = "stack")+
    theme_minimal() +
    ylab("% content") +
    scale_y_continuous(breaks = c(50, 100)) +
    temp_theme

  # Read lengths
  dt_read_lengths <- readLengthTable(NULL, output.dir = path)
  dt_read_lengths <- dt_read_lengths[perc_of_counts_per_sample > 1, ]
  dt_read_lengths[, sample_id := as.factor(sample_id)]
  gg_read_lengths <- ggplot(dt_read_lengths, aes(y = perc_of_counts_per_sample, x = `read length`, fill = sample_id)) +
    geom_bar(stat="identity", position = "dodge")+
    ylab("% counts") +
    facet_wrap(  ~ sample_id, nrow = length(levels(dt_read_lengths$sample_id))) +
    scale_y_continuous(breaks = c(15, 30)) +
    theme_minimal() +
    temp_theme

  # mRNA regions
  mRNA_regions <- colnames(stats)[colnames(stats) %in% c("LEADERS", "CDS", "TRAILERs")]
  dt_mRNA_regions <- dt_plot[(variable %in% mRNA_regions),]

  gg_mRNA_regions <- ggplot(dt_mRNA_regions, aes(y = value, x = sample_id)) +
    geom_bar(aes(fill = variable), stat="identity", position = "fill")+
    ylab("ratio") +
    scale_y_continuous(breaks = c(0.5, 1.0)) +
    theme_minimal() +
    temp_theme

  lay <- rbind(c(2),
               c(2),
               c(2),
               c(1,3),
               c(1,3))
  plot_list <- list(gg_STAT, gg_read_lengths, gg_mRNA_regions)
  final <- gridExtra::grid.arrange(grobs = plot_list, layout_matrix = lay)

  if (!is.null(output.dir)) {
    ggsave(file.path(output.dir, paste0("STATS_plot", plot.ext)), final, width = 13,
           height = 8, dpi = 300)
  }
  return(gg_STAT)
}

#' Correlation plots between all samples
#'
#' Get 2 correlation plots of raw counts and log2(count + 1) over
#' selected region in: c("mrna", "leaders", "cds", "trailers")
#' @inheritParams QCplots
#' @param output.dir directory to save to, 2 files named: cor_plot.pdf and
#' cor_plot_log2.pdf
#' @param type which value to use, "fpkm", alternative "counts".
#' @param height numeric, default 400 (in mm)
#' @param width numeric, default 400 (in mm)
#' @param size numeric, size of dots, default 0.15.
#' @return invisible(NULL)
#' @importFrom GGally wrap
correlation.plots <- function(df, output.dir,
                              region = "mrna", type = "fpkm",
                              height = 400, width = 400, size = 0.15, plot.ext = ".pdf") {
  message("- Correlation plots")
  # Load fpkm values
  data_for_pairs <- countTable(df, region, type = type)
  # Settings for points
  point_settings <- list(continuous = wrap("points", alpha = 0.3, size = size),
                         combo = wrap("dot", alpha = 0.4, size=0.2))
  message("  - raw scaled fpkm")
  paired_plot <- ggpairs(as.data.frame(data_for_pairs),
                         columns = 1:ncol(data_for_pairs),
                         lower = point_settings)
  ggsave(pasteDir(output.dir, paste0("cor_plot", plot.ext)), paired_plot,
         height = height, width = width, units = 'mm', dpi = 300)
  message("  - log2 scaled fpkm")
  paired_plot <- ggpairs(as.data.frame(log2(data_for_pairs + 1)),
                         columns = 1:ncol(data_for_pairs),
                         lower = point_settings)
  ggsave(pasteDir(output.dir, paste0("cor_plot_log2", plot.ext)), paired_plot,
         height = height, width = width, units = 'mm', dpi = 300)
  return(invisible(NULL))
}

#' Quality control for pshifted Ribo-seq data
#'
#' Combines several statistics from the pshifted reads into a plot:\cr
#' -1 Coding frame distribution per read length\cr
#' -2 Alignment statistics\cr
#' -3 Biotype of non-exonic pshifted reads\cr
#' -4 mRNA localization of pshifted reads\cr
#' @param type type of library loaded, default pshifted,
#'  warning if not pshifted might crash if too many read lengths!
#' @param width width of plot, default 6.6 (in inches)
#' @param height height of plot, default 4.5 (in inches)
#' @param weight which column in reads describe duplicates, default "score".
#' @param bar.position character, default "dodge". Should Ribo-seq frames
#' per read length be positioned as "dodge" or "stack" (on top of each other).
#' @inheritParams QCstats.plot
#' @inheritParams outputLibs
#' @return ggplot object as a grid
#' @importFrom ggplot2 theme
#' @export
#' @examples
#' df <- ORFik.template.experiment()
#' df <- df[3,] #lets only p-shift RFP sample at index 3
#' #shiftFootprintsByExperiment(df)
#' #RiboQC.plot(df)
RiboQC.plot <- function(df, output.dir = file.path(dirname(df$filepath[1]), "QC_STATS/"),
                        width = 6.6, height = 4.5, plot.ext = ".pdf",
                        type = "pshifted", weight = "score", bar.position = "dodge",
                        BPPARAM = BiocParallel::SerialParam(progressbar = TRUE)) {
  stats <- QCstats(df)
  stopifnot(bar.position %in% c("stack", "dodge"))

  if (colnames(stats)[1] == "V1") colnames(stats)[1] <- "sample_id"

  stats$sample_id <-  factor(stats$Sample,
                             labels = as.character(seq(length(stats$Sample))),
                             levels = stats$Sample)
  stats$Sample <-  factor(stats$Sample, levels = stats$Sample)
  colnames(stats) <- gsub("percentage", "%", colnames(stats))
  stats[,(seq.int(ncol(stats))[-c(1,2)]):= lapply(.SD, as.numeric),
        .SDcols = seq.int(ncol(stats))[-c(1,2)]]
  dt_plot <- melt(stats, id.vars = c("Sample", "sample_id"))

  step_counts <- c("mRNA", "rRNA")
  stat_regions <- colnames(stats)[c(which(colnames(stats) %in% step_counts))]
  dt_STAT <- dt_plot[(variable %in% stat_regions),]
  dt_STAT_normalized <- copy(dt_STAT)
  dt_STAT_normalized[, sample_total := sum(value), by = .(sample_id)]
  dt_STAT_normalized[, percentage := (value / sample_total)*100]

  # Assign themes
  temp_theme <-  theme(legend.text=element_text(size=8),
                       legend.key.size = unit(0.3, "cm"),
                       plot.title = element_text(size=11),
                       strip.text.x = element_blank(),
                       panel.grid.minor = element_blank())
  rm.minor <- theme(legend.text=element_text(size=8),
                    legend.key.size = unit(0.3, "cm"),
                    plot.title = element_text(size=11),
                    panel.grid.minor = element_blank())


  outputLibs(df, type = type)
  cds <- loadRegion(df, part = "cds")
  libs <- bamVarName(df)

  # Frame distribution over all
  frame_sum_per1 <- bplapply(libs, FUN = function(lib, cds, weight) {
    total <- regionPerReadLength(cds, get(lib, mode = "S4"),
                                 withFrames = TRUE, scoring = "frameSumPerL",
                                 weight = weight, drop.zero.dt = TRUE)
    total[, length := fraction]
    #hits <- get(lib, mode = "S4")[countOverlaps(get(lib, mode = "S4"), cds) > 0]
    total[, fraction := rep(lib, nrow(total))]
  }, cds = cds, weight = weight, BPPARAM = BPPARAM)
  frame_sum_per <- rbindlist(frame_sum_per1)

  frame_sum_per$frame <- as.factor(frame_sum_per$frame)
  frame_sum_per$fraction <- as.factor(frame_sum_per$fraction)
  frame_sum_per[, percent := (score / sum(score))*100, by = fraction]
  frame_sum_per[, fraction := factor(fraction, levels = libs,
                                     labels = bamVarName(df, skip.libtype = TRUE), ordered = TRUE)]

  frame_sum_per[, fraction := factor(fraction, levels = unique(fraction), ordered = TRUE)]
  # stacked
  gg_frame_per_stack <- ggplot(frame_sum_per, aes(x = length, y = percent)) +
    geom_bar(aes(fill = frame), stat="identity", position = bar.position)+
    scale_x_continuous(breaks = unique(frame_sum_per$length)) +
    theme_minimal() +
    rm.minor+
    xlab("read length") +
    ylab("percent") +
    facet_wrap(  ~ fraction, ncol = 1, scales = "free_y") +
    scale_y_continuous(breaks = c(15, 35))
  gg_frame_per_stack

  # all_tx_types > 1%
  all_tx_types <- which(colnames(stats) == "All_tx_types") + 1
  all_tx_regions <- colnames(stats)[c(all_tx_types:length(colnames(stats)))]
  all_tx_regions <- c("mRNA", all_tx_regions)
  dt_all_tx_regions<- dt_plot[(variable %in% all_tx_regions),]
  dt_all_tx_regions[, sample_total := sum(value), by = .(sample_id)]
  dt_all_tx_regions[, percentage := (value / sample_total)*100]
  dt_all_tx_other <- dt_all_tx_regions[percentage < 1,]
  dt_all_tx_regions[percentage < 1, variable := "other"]
  gg_all_tx_regions <-
    ggplot(dt_all_tx_regions, aes(y = percentage, x = sample_id)) +
    geom_bar(aes(fill = variable), stat="identity", position = "stack")+
    ylab("percent") +
    xlab("sample id") +
    theme_minimal() +
    temp_theme +
    labs(fill = "tx. type")  +
    scale_y_continuous(breaks = c(50, 100))
  gg_all_tx_regions
  # all_tx_types <= 1%
  gg_all_tx_other <-
    ggplot(dt_all_tx_other, aes(y = percentage, x = sample_id)) +
    geom_bar(aes(fill = variable), stat="identity", position = "stack")+
    ylab("percent") +
    xlab("sample id") +
    theme_minimal() +
    temp_theme +
    labs(fill = "tx. other") +
    scale_fill_grey()  +
    scale_y_continuous(n.breaks = 3)
  gg_all_tx_other

  # Aligned reads
  dt_aligned <- dt_plot[(variable %in% "Aligned_reads"),]
  gg_all_mrna <- ggplot(dt_aligned, aes(y = value, x = sample_id)) +
    geom_bar(stat="identity", position = "stack")+
    ylab("alignments") +
    xlab("sample id") +
    theme_minimal() +
    temp_theme +
    labs(fill = "region") +
    scale_y_continuous(n.breaks = 3, labels = function(x) format(x, scientific = TRUE))
  gg_all_mrna
  # 5' UTR, CDS & 3' UTR
  mRNA_regions <- colnames(stats)[colnames(stats) %in% c("LEADERS", "CDS", "TRAILERs")]
  dt_mRNA_regions <- dt_plot[(variable %in% mRNA_regions),]
  dt_mRNA_regions[, variable := as.character(variable)]
  dt_mRNA_regions[variable == "LEADERS", variable := "5'UTR"]
  dt_mRNA_regions[variable == "TRAILERs", variable := "3'UTR"]
  dt_mRNA_regions[, variable := factor(as.character(dt_mRNA_regions$variable),
                                       levels = c(unique(dt_mRNA_regions$variable)),
                                       ordered = TRUE)]
  dt_mRNA_regions[, sample_total := sum(value), by = .(sample_id)]
  dt_mRNA_regions[, percentage := (value / sample_total)*100]
  gg_mRNA_regions <- ggplot(dt_mRNA_regions, aes(y = percentage, x = sample_id)) +
    geom_bar(aes(fill = variable), stat="identity", position = "stack")+
    ylab("percent") +
    xlab("sample id") +
    scale_y_continuous(breaks = c(50, 100)) +
    theme_minimal() +
    temp_theme +
    labs(fill = "region")

  lay <- rbind(c(2, 1),
               c(2, 3),
               c(2, 4),
               c(2, 5))

  plot_list <- list(gg_all_mrna, gg_frame_per_stack, gg_all_tx_regions, gg_all_tx_other, gg_mRNA_regions)
  final <- gridExtra::grid.arrange(grobs = plot_list, layout_matrix = lay)
  if (!is.null(output.dir)) {
    ggsave(file.path(output.dir, paste0("STATS_plot_Ribo-seq_Check", plot.ext)), final,
           width = width, height = height, dpi = 300)
  }
  return(final)
}

