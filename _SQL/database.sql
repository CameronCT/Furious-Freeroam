-- MySQL Script generated by MySQL Workbench
-- Sat Apr 22 23:46:01 2017
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema samp
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema samp
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `samp` DEFAULT CHARACTER SET utf8 ;
USE `samp` ;

-- -----------------------------------------------------
-- Table `samp`.`accounts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `samp`.`accounts` (
  `a_id` INT NOT NULL AUTO_INCREMENT,
  `a_name` CHAR(24) NOT NULL,
  `a_password` VARCHAR(64) NOT NULL,
  `a_email` CHAR(128) NOT NULL,
  `a_money` INT(11) NOT NULL DEFAULT 0,
  `a_score` INT(11) NOT NULL DEFAULT 0,
  `a_kills` INT(11) NOT NULL DEFAULT 0,
  `a_deaths` INT(11) NOT NULL DEFAULT 0,
  `a_datetime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`a_id`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;